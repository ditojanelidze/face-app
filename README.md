# Nightlife Venue Verification Platform

A Rails 8 API for digital guest verification and face control at bars and clubs.

## Features

- **User Authentication**: Passwordless OTP-based authentication via SMS
- **Profile Management**: Photo and ID card upload for verification
- **Venue Discovery**: Browse venues and upcoming events
- **Approval System**: Request global or event-specific access
- **QR Code Entry**: Receive QR codes upon approval for venue entry
- **Admin Dashboard**: Manage venues, events, and approval requests
- **QR Scanner**: Validate guest QR codes at entry

## Tech Stack

- Ruby on Rails 8 (API-only)
- PostgreSQL
- JWT for authentication
- Active Storage for file uploads
- RQRCode for QR code generation
- Twilio for SMS (optional)
- Swagger/OpenAPI documentation (rswag)

## Setup

### Prerequisites

- Ruby 3.x
- PostgreSQL
- Bundler

### Installation

```bash
# Install dependencies
bundle install

# Create and migrate database
rails db:create db:migrate

# Seed sample data
rails db:seed

# Start the server
rails server
```

### Configuration

For SMS functionality, set Twilio credentials:

```bash
export TWILIO_ACCOUNT_SID=your_account_sid
export TWILIO_AUTH_TOKEN=your_auth_token
export TWILIO_PHONE_NUMBER=your_phone_number
```

Or add to Rails credentials:

```bash
rails credentials:edit
```

```yaml
twilio:
  account_sid: your_account_sid
  auth_token: your_auth_token
  phone_number: your_phone_number
```

**Note**: In development, OTP codes are logged to the console when Twilio is not configured.

## API Documentation (Swagger)

Interactive API documentation is available via Swagger UI:

```
http://localhost:3000/api-docs
```

The Swagger UI provides:
- Complete API reference with request/response schemas
- Interactive "Try it out" feature to test endpoints
- Authentication setup for testing protected routes
- Detailed descriptions of all parameters and responses

## API Endpoints

### User Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/request_otp` | Request OTP code |
| POST | `/api/v1/auth/register` | Register with OTP |
| POST | `/api/v1/auth/login` | Login with OTP |
| POST | `/api/v1/auth/refresh` | Refresh access token |
| DELETE | `/api/v1/auth/logout` | Logout |
| GET | `/api/v1/auth/check_phone` | Check if phone is registered |

### User Profile

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/profile` | Get profile |
| PATCH | `/api/v1/profile` | Update profile |
| POST | `/api/v1/profile/upload_photo` | Upload profile photo |
| POST | `/api/v1/profile/upload_id_card` | Upload ID card |
| GET | `/api/v1/profile/approvals` | Get all approvals |
| GET | `/api/v1/profile/active_approvals` | Get active approvals |

### Venues & Events (Users)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/venues` | List all venues |
| GET | `/api/v1/venues/:id` | Get venue details |
| GET | `/api/v1/venues/:id/events` | Get venue events |

### Approvals (Users)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/approvals` | List user's approvals |
| GET | `/api/v1/approvals/:id` | Get approval details |
| POST | `/api/v1/approvals` | Request approval |
| GET | `/api/v1/approvals/:id/qr_code` | Get QR code |

### Admin Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/admin/auth/register` | Register admin |
| POST | `/api/v1/admin/auth/login` | Admin login |

### Admin Venues

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/admin/venues` | List admin's venues |
| POST | `/api/v1/admin/venues` | Create venue |
| GET | `/api/v1/admin/venues/:id` | Get venue |
| PATCH | `/api/v1/admin/venues/:id` | Update venue |
| DELETE | `/api/v1/admin/venues/:id` | Delete venue |

### Admin Events

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/admin/venues/:venue_id/events` | List events |
| GET | `/api/v1/admin/venues/:venue_id/events/upcoming` | Upcoming events |
| POST | `/api/v1/admin/venues/:venue_id/events` | Create event |
| GET | `/api/v1/admin/venues/:venue_id/events/:id` | Get event |
| PATCH | `/api/v1/admin/venues/:venue_id/events/:id` | Update event |
| DELETE | `/api/v1/admin/venues/:venue_id/events/:id` | Delete event |

### Admin Approvals

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/admin/venues/:venue_id/approvals` | List approvals |
| GET | `/api/v1/admin/venues/:venue_id/approvals/pending` | Pending approvals |
| GET | `/api/v1/admin/venues/:venue_id/approvals/:id` | Get approval details |
| POST | `/api/v1/admin/venues/:venue_id/approvals/:id/approve` | Approve user |
| POST | `/api/v1/admin/venues/:venue_id/approvals/:id/reject` | Reject user |

### QR Scanner

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/admin/venues/:venue_id/scan` | Scan & validate QR |
| POST | `/api/v1/admin/venues/:venue_id/validate` | Validate QR (preview) |

## Authentication

All authenticated endpoints require the `Authorization` header:

```
Authorization: Bearer <access_token>
```

## Sample Data

After running `rails db:seed`:

**Venue Admin Accounts:**
- Email: `admin@skybar.com` | Password: `password123`
- Email: `admin@neonclub.com` | Password: `password123`

**Test User Phone:** `+15551234567`

## Example Requests

### Request OTP

```bash
curl -X POST http://localhost:3000/api/v1/auth/request_otp \
  -H "Content-Type: application/json" \
  -d '{"auth": {"phone_number": "+15551234567"}}'
```

### Register

```bash
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"auth": {"phone_number": "+15551234567", "code": "123456", "first_name": "John", "last_name": "Doe"}}'
```

### Admin Login

```bash
curl -X POST http://localhost:3000/api/v1/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{"auth": {"email": "admin@skybar.com", "password": "password123"}}'
```

### Request Approval

```bash
curl -X POST http://localhost:3000/api/v1/approvals \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <access_token>" \
  -d '{"approval": {"venue_id": 1, "approval_type": "global"}}'
```

### Scan QR Code

```bash
curl -X POST http://localhost:3000/api/v1/admin/venues/1/scan \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <admin_token>" \
  -d '{"qr_code_data": "uuid-from-qr-code"}'
```

## License

MIT
