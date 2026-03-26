import React, { useState } from 'react';
import { Button, Typography, message, Card, Row, Col } from 'antd';
import { LoginOutlined, LockOutlined } from '@ant-design/icons';
import { useMsal } from '@azure/msal-react';
import { Navigate } from 'react-router-dom';
import { loginRequest } from '../auth/authProvider';
import { useAuth } from '../hooks/useAuth';
import logo from '../assets/logo.png';
import './LoginPage.css';

const LoginPage: React.FC = () => {
  const { instance } = useMsal();
  const { isAuthenticated } = useAuth();
  const [loading, setLoading] = useState(false);

  if (isAuthenticated) {
    return <Navigate to="/dashboard" replace />;
  }

  const handleLogin = async () => {
    setLoading(true);
    try {
      await instance.loginRedirect(loginRequest);
    } catch (err: any) {
      message.error(`Sign-in failed: ${err?.message ?? 'Unknown error'}`);
      setLoading(false);
    }
  };

  return (
    <div className="login-container">
      <div className="login-content">
        <Row gutter={32} justify="center" align="middle" style={{ minHeight: '100vh' }}>
          <Col xs={22} sm={20} md={12} lg={10} xl={8}>
            <Card
              className="login-card"
              bordered={false}
              style={{
                boxShadow: '0 20px 60px rgba(0, 0, 0, 0.3)',
                borderRadius: 16,
                background: 'rgba(255, 255, 255, 0.95)',
                backdropFilter: 'blur(10px)',
              }}
            >
              {/* Logo & Title */}
              <div style={{ textAlign: 'center', marginBottom: 32 }}>
                <img
                  src={logo}
                  alt="Task Tracker Logo"
                  style={{
                    height: 80,
                    width: 80,
                    marginBottom: 16,
                    objectFit: 'contain',
                    opacity: 0.9,
                    filter: 'drop-shadow(0 2px 4px rgba(0, 0, 0, 0.1))',
                    transition: 'all 0.3s ease',
                  }}
                />
                <Typography.Title
                  level={2}
                  style={{
                    margin: '0 0 8px',
                    color: '#0f1a2d',
                    fontSize: 28,
                    fontWeight: 700,
                  }}
                >
                  Task Tracker
                </Typography.Title>
                <Typography.Text style={{ color: '#666', fontSize: 14 }}>
                  Plan. Track. Deliver.
                </Typography.Text>
              </div>

              {/* Divider */}
              <div
                style={{
                  height: 1,
                  background: 'linear-gradient(to right, transparent, #ddd, transparent)',
                  marginBottom: 24,
                }}
              />

              {/* Security Badge */}
              <div
                style={{
                  background: 'rgba(62, 190, 255, 0.1)',
                  border: '1px solid rgba(62, 190, 255, 0.2)',
                  borderRadius: 8,
                  padding: '12px 16px',
                  marginBottom: 24,
                  display: 'flex',
                  alignItems: 'center',
                  gap: 8,
                }}
              >
                <LockOutlined style={{ color: '#3ebeff', fontSize: 16 }} />
                <Typography.Text style={{ color: '#0f1a2d', fontSize: 13, margin: 0 }}>
                  <strong>Enterprise Access</strong> with Microsoft Azure AD
                </Typography.Text>
              </div>

              {/* Login Button */}
              <Button
                type="primary"
                size="large"
                block
                icon={<LoginOutlined />}
                loading={loading}
                onClick={handleLogin}
                style={{
                  background: 'linear-gradient(135deg, #3ebeff, #5b6ef5)',
                  border: 'none',
                  fontWeight: 600,
                  fontSize: 15,
                  height: 44,
                  marginBottom: 16,
                }}
              >
                Continue with Microsoft
              </Button>

              <Typography.Text
                style={{
                  color: '#999',
                  fontSize: 12,
                  display: 'block',
                  textAlign: 'center',
                  marginBottom: 24,
                }}
              >
                Use your organization account to sign in
              </Typography.Text>

              {/* Divider */}
              <div
                style={{
                  height: 1,
                  background: 'linear-gradient(to right, transparent, #ddd, transparent)',
                  marginBottom: 20,
                }}
              />

              {/* Footer Security Info */}
              <div
                style={{
                  marginTop: 24,
                  paddingTop: 16,
                  textAlign: 'center',
                }}
              >
                <Typography.Text
                  style={{
                    color: '#999',
                    fontSize: 11,
                    lineHeight: 1.8,
                  }}
                >
                  🔐 Your credentials are secured by Microsoft Azure AD
                </Typography.Text>
              </div>
            </Card>
          </Col>
        </Row>
      </div>
    </div>
  );
};

export default LoginPage;
