"""Pydantic schemas for Project entities."""

from __future__ import annotations

from datetime import date, datetime
from typing import Optional
from uuid import UUID

from pydantic import BaseModel, Field, model_validator
from app.schemas.user_schema import UserSummary


class ProjectCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=200)
    description: Optional[str] = Field(None, max_length=2000)
    start_date: Optional[date] = Field(None, description="Start date (must be today or in the future)")
    end_date: Optional[date] = Field(None, description="End date (must be after start_date or today)")

    @model_validator(mode="after")
    def _validate_dates(self):
        today = date.today()
        
        # start_date cannot be in the past
        if self.start_date and self.start_date < today:
            raise ValueError("start_date cannot be in the past")
        
        # end_date cannot be in the past
        if self.end_date and self.end_date < today:
            raise ValueError("end_date cannot be in the past")
        
        # end_date must not be before start_date
        if self.start_date and self.end_date and self.end_date < self.start_date:
            raise ValueError("end_date must not be before start_date")
        
        return self


class ProjectUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=200)
    description: Optional[str] = Field(None, max_length=2000)
    start_date: Optional[date] = Field(None, description="Start date (must be today or in the future)")
    end_date: Optional[date] = Field(None, description="End date (must be after start_date or today)")

    @model_validator(mode="after")
    def _validate_dates(self):
        today = date.today()
        
        # start_date cannot be in the past
        if self.start_date and self.start_date < today:
            raise ValueError("start_date cannot be in the past")
        
        # end_date cannot be in the past
        if self.end_date and self.end_date < today:
            raise ValueError("end_date cannot be in the past")
        
        # end_date must not be before start_date
        if self.start_date and self.end_date and self.end_date < self.start_date:
            raise ValueError("end_date must not be before start_date")
        
        return self


class ProjectResponse(BaseModel):
    id: UUID
    name: str
    description: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    owner_id: UUID
    owner: Optional[UserSummary] = None
    created_at: datetime

    class Config:
        from_attributes = True
