"""Security dependencies – current-user resolution."""

from __future__ import annotations

import logging
from typing import Optional

from fastapi import Depends, HTTPException
from sqlalchemy.orm import Session

from app.auth.azure_auth import validate_token
from app.database.session import get_db  # re-exported for backward compatibility
from app.models.user import User

logger = logging.getLogger(__name__)


def get_current_user(
    db: Session = Depends(get_db),
    payload: dict = Depends(validate_token),
) -> User:
    """Resolve the current user from the validated token.

    If the user does not exist yet, auto-provision them with Read Only User
    role (first SSO login). An admin can elevate their role via PATCH /users/{id}/role.
    
    Checks for Azure AD groups in token and assigns appropriate roles if configured.
    """
    email: Optional[str] = (
        payload.get("preferred_username")
        or payload.get("email")
        or payload.get("upn")
    )
    if not email:
        raise HTTPException(status_code=400, detail="Token does not contain an email claim")

    user = db.query(User).filter(User.email == email).first()

    if not user:
        name = payload.get("name", email.split("@")[0])
        user = User(name=name, email=email)

        # Determine initial role based on Azure AD groups (if configured) or default to Read Only User
        from app.models.role import Role
        initial_role_name = "Read Only User"
        
        # Check for Azure AD groups to determine role
        groups = payload.get("groups", [])
        if groups:
            # If settings define group-to-role mappings, use them
            group_role_mapping = {
                # Example: "admin-group-id": "Admin",
                # "manager-group-id": "Manager"
            }
            for group_id in groups:
                if group_id in group_role_mapping:
                    initial_role_name = group_role_mapping[group_id]
                    break
        
        user_role = db.query(Role).filter(Role.name == initial_role_name).first()
        if user_role:
            user.roles.append(user_role)
        else:
            # Fallback: ensure at least one role is assigned
            fallback_role = db.query(Role).filter(Role.name == "Read Only User").first()
            if fallback_role:
                user.roles.append(fallback_role)

        db.add(user)
        db.commit()
        db.refresh(user)
        logger.info("Auto-provisioned user %s (%s) with role %s", user.name, user.email, initial_role_name)

    if not user.is_active:
        raise HTTPException(status_code=403, detail="User account is disabled")

    return user
