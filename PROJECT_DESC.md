# Nightlife Venue Verification Platform

## Overview

A dual-sided application that enables bars and clubs to digitally manage guest verification and face control.

The platform connects:

- **Users (Customers)** who request access approval
- **Venues (Bars/Clubs)** who review and approve or reject requests

Approved users receive a QR code that is scanned at entry for validation.

---

# User Registration & Authentication

## Registration (Sign Up)

Users can register using:

- First Name (required)
- Last Name (required)
- Phone Number (required)

No password is required.

---

## Phone Verification (OTP Authentication)

Authentication is fully passwordless and based on SMS verification codes.

### Flow:

#### Login

1. User clicks on login button
2. User enters phone number
3. Otp is generated and sent via SMS
4. User enters received OTP
6. If valid and not expired: User logs int

#### Registration
1. User clicks on register button
2. User enters first name, last name, phone number
3. User has status "pending verification"
3. Otp is generated and sent via SMS
4. User enters received OTP
6. User registers and has status "verified" and logs in

### OTP Rules:

- OTP expiration: 5 minutes
- Limited retry attempts
- Single phone number = single account


---

## Session Management

After successful authentication:

- System issues:
    - Short-lived Access Token (e.g., 15–60 minutes)
    - Long-lived Refresh Token (valid for 30 days)

- Refresh token is stored securely (server-side cache, e.g., Redis).
- User remains logged in for up to 30 days without re-verifying via SMS.
- After refresh token expiration, full OTP login is required.

---

# User Profile

## Basic Profile (Created at Registration)

- First Name
- Last Name
- Phone Number
- Phone Verified (boolean)

---

## Extended Profile (Required Before Approval Requests)

Users must complete the following before requesting venue approval:

### Mandatory:
- Profile Photo (image upload)
- Government-issued ID (front side image)

### Optional:
- Facebook profile link
- Instagram profile link
- LinkedIn profile link

Users can:
- Edit profile information
- Replace uploaded images
- View approval history
- View active approvals

---

# Venue Admin

User might have different admin_roles assigned


Admins can:
- Review incoming approval requests
- View full user profile:
    - Name
    - Profile photo
    - Social links (if provided)
    - ID image
- Approve or reject users
- Create and manage events
- Scan QR codes at entry

---

# Approval System

## Approval Types

### 1. Global Approval
- User is approved for general access to the venue.
- May apply to all events (if event allows global approvals).

### 2. Event-Specific Approval
- User is approved only for a specific event.

---

# Event Management

Admins can create events with:

- Event Name
- Date and Time
- `allowGlobalApproval` (boolean)

If `allowGlobalApproval = true`:
- Users with global approval can enter the event automatically.

If `allowGlobalApproval = false`:
- Event requires separate approval.

---

# Approval Request Flow

1. User selects a venue.
2. User chooses:
    - Request Global Approval
    - Request Event Approval
3. Admin reviews user profile.
4. Admin approves or rejects.

Approval status:
- Pending
- Approved
- Rejected

---

# QR Code System

When approval is granted:

- System generates a unique QR code.
- QR code is linked to:
    - User ID
    - Venue ID
    - Approval type (global or event)
    - Event ID (if applicable)
    - Expiration status

---

## QR Validation at Entry

1. Admin scans QR code.
2. System validates:
    - Approval exists
    - Approval is active
    - Event matches (if event-specific)
    - QR is not expired
    - (Optional) QR not already used

If valid → Entry allowed  
If invalid → Entry denied

---

# Core Entities (Conceptual Model)

## User
- id
- firstName
- lastName
- phoneNumber
- phoneVerified
- profilePhotoUrl
- idCardImageUrl
- socialLinks
- createdAt
- updatedAt

## Venue
- id
- name
- adminAccountId

## Event
- id
- venueId
- name
- dateTime
- allowGlobalApproval

## Approval
- id
- userId
- venueId
- eventId (nullable)
- type (global | event)
- status (pending | approved | rejected)
- qrCodeData
- createdAt
- expiresAt (optional)

## Session
- userId
- refreshToken
- expiresAt
- deviceInfo (optional)

## OtpCode
- phoneNumber
- code
- expiresAt
- attempts

---

# System Goals

- Digitize face control process
- Enable pre-screening before arrival
- Reduce entrance conflicts
- Improve venue-level control and record keeping
- Provide QR-based secure entry validation


# Tech Stack (suggested):
- Backend: Rails 8 API only
- Database: PostgreSQL
- SMS Service: Twilio or similar
- QR Code Generation: RQRCode or similar
- Authentication: JWT token

For all the technical challenges, we should use Rails 8 tools as much as possible