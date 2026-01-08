# Authentication Domain Specification

## Overview

Authentication provides secure user identity management using Rails 8 built-in authentication (`has_secure_password`). The system supports session-based authentication for web access and API tokens for programmatic access.

## Data Models

### User

| Field | Type | Constraints |
|-------|------|-------------|
| `id` | bigint | Primary key |
| `email_address` | string | NOT NULL, UNIQUE, normalised lowercase |
| `password_digest` | string | NOT NULL |
| `created_at` | datetime | NOT NULL |
| `updated_at` | datetime | NOT NULL |

### Session

| Field | Type | Constraints |
|-------|------|-------------|
| `id` | bigint | Primary key |
| `user_id` | bigint | Foreign key, NOT NULL |
| `ip_address` | string | Optional |
| `user_agent` | string | Optional |
| `created_at` | datetime | NOT NULL |
| `updated_at` | datetime | NOT NULL |

### ApiToken

| Field | Type | Constraints |
|-------|------|-------------|
| `id` | bigint | Primary key |
| `user_id` | bigint | Foreign key, NOT NULL |
| `token` | string | NOT NULL, UNIQUE |
| `name` | string | Optional |
| `last_used_at` | datetime | Optional |
| `created_at` | datetime | NOT NULL |
| `updated_at` | datetime | NOT NULL |

### Associations

```
User
  HAS MANY Sessions
  HAS MANY ApiTokens
  HAS MANY Bookmarks
  HAS MANY Galleries
  HAS MANY Albums
  HAS MANY Photos

Session
  BELONGS TO User

ApiToken
  BELONGS TO User
```

---

## Requirements

### REQ-AUTH-001: User Registration

**Description**: The system SHALL support user account creation.

**Acceptance Criteria**:
1. Users MUST provide a valid email address
2. Users MUST provide a password
3. Email addresses MUST be unique (case-insensitive)
4. Email addresses MUST be normalised to lowercase
5. Passwords MUST be securely hashed using bcrypt

### REQ-AUTH-002: User Login

**Description**: Users SHALL be able to authenticate with email and password.

**Acceptance Criteria**:
1. The login page MUST be accessible at `/session/new`
2. Users MUST provide email and password
3. The system MUST verify credentials using `has_secure_password`
4. Successful login MUST create a new Session record
5. Failed login MUST display an error message
6. The system SHALL NOT reveal whether email exists on failure

### REQ-AUTH-003: Rate Limiting

**Description**: Login attempts SHALL be rate limited to prevent brute force attacks.

**Acceptance Criteria**:
1. Login attempts MUST be limited to 10 per 3 minutes
2. Exceeding the limit MUST redirect with an error message
3. Rate limiting MUST be applied per IP address

### REQ-AUTH-004: Session Management

**Description**: The system SHALL maintain secure user sessions.

**Acceptance Criteria**:
1. Sessions MUST be stored in the database
2. Sessions MUST record IP address and user agent
3. The `Current` model MUST provide access to the current session
4. Session tokens MUST be stored in secure, HTTP-only cookies
5. Users MUST be able to log out (destroy session)

### REQ-AUTH-005: Password Reset

**Description**: Users SHALL be able to reset forgotten passwords.

**Acceptance Criteria**:
1. Password reset flow MUST be available via `/passwords`
2. Reset tokens MUST be sent via email
3. Reset tokens MUST have an expiration time
4. Users MUST be able to set a new password with a valid token

### REQ-AUTH-006: Authenticated Access Control

**Description**: Controllers SHALL be able to restrict access to authenticated users.

**Acceptance Criteria**:
1. The `require_authentication` method MUST enforce login
2. The `allow_unauthenticated_access` method MUST whitelist specific actions
3. The `authenticated?` helper MUST return authentication status
4. `Current.session.user` MUST return the authenticated user
5. Unauthenticated requests to protected routes MUST redirect to login

### REQ-AUTH-007: API Token Authentication

**Description**: Users SHALL be able to generate API tokens for programmatic access.

**Acceptance Criteria**:
1. API tokens MUST be manageable at `/api_tokens`
2. Tokens MUST be displayed only once upon creation
3. Tokens MUST be unique and securely generated
4. Users MUST be able to name their tokens
5. Users MUST be able to revoke (delete) tokens
6. The system SHOULD track `last_used_at` for tokens

### REQ-AUTH-008: Authorisation

**Description**: Users SHALL only access their own content.

**Acceptance Criteria**:
1. Users MUST only see their own bookmarks when authenticated
2. Users MUST only see their own photos/albums/galleries when authenticated
3. Public content MUST be visible to all users
4. Edit/delete actions MUST be restricted to content owners
5. The system MUST scope queries to `Current.session.user`

---

## Scenarios

### Scenario: Successful Login

**Given** a registered user with email "user@example.com"
**When** the user submits correct credentials
**Then** a new Session SHALL be created
**And** the user SHALL be redirected to the dashboard
**And** the session cookie SHALL be set

### Scenario: Failed Login

**Given** a registered user with email "user@example.com"
**When** the user submits an incorrect password
**Then** NO session SHALL be created
**And** an error message SHALL be displayed
**And** the user SHALL remain on the login page

### Scenario: Rate Limited Login

**Given** a user who has made 10 login attempts in 3 minutes
**When** the user attempts another login
**Then** the request SHALL be rejected
**And** the user SHALL be redirected with a "Try again later" message

### Scenario: Logout

**Given** an authenticated user
**When** the user clicks logout
**Then** the Session record SHALL be destroyed
**And** the session cookie SHALL be cleared
**And** the user SHALL be redirected to the login page

### Scenario: Accessing Protected Route Without Authentication

**Given** an unauthenticated user
**When** the user tries to access `/dashboard`
**Then** the user SHALL be redirected to `/session/new`

### Scenario: Creating an API Token

**Given** an authenticated user at `/api_tokens/new`
**When** the user provides a token name and submits
**Then** a new ApiToken SHALL be created
**And** the token value SHALL be displayed once
**And** the user SHALL be warned to save the token

### Scenario: Revoking an API Token

**Given** an authenticated user with an API token
**When** the user deletes the token
**Then** the ApiToken record SHALL be destroyed
**And** the token SHALL no longer authenticate requests

### Scenario: Public Content Access Without Login

**Given** a public bookmark exists
**When** an unauthenticated user views the bookmarks index
**Then** the public bookmark SHALL be visible
**And** the user SHALL NOT need to log in

### Scenario: Private Content Access Without Login

**Given** a private bookmark exists
**When** an unauthenticated user views the bookmarks index
**Then** the private bookmark SHALL NOT be visible

### Scenario: User Data Isolation

**Given** User A has bookmarks
**And** User B has bookmarks
**When** User A views their bookmarks index
**Then** only User A's bookmarks SHALL be displayed
**And** User B's bookmarks SHALL NOT be visible

### Scenario: Email Normalisation

**Given** a user registering with "USER@EXAMPLE.COM"
**When** the account is created
**Then** the email SHALL be stored as "user@example.com"
**And** login with "USER@EXAMPLE.COM" SHALL succeed
