# Bookmarks Domain Specification

## Overview

Bookmarks provide Delicious-style web link management with tagging, short URLs for sharing, and public/private visibility controls.

## Data Model

### Bookmark

| Field | Type | Constraints |
|-------|------|-------------|
| `id` | bigint | Primary key |
| `user_id` | bigint | Foreign key, NOT NULL |
| `title` | string | NOT NULL |
| `description` | text | Optional |
| `url` | string | NOT NULL, valid HTTP/HTTPS URL |
| `short_code` | string | NOT NULL, UNIQUE, 6 alphanumeric chars |
| `is_public` | boolean | NOT NULL, default: false |
| `created_at` | datetime | NOT NULL |
| `updated_at` | datetime | NOT NULL |

### Associations

- Bookmark BELONGS TO User
- Bookmark HAS MANY Tags (through Taggings, polymorphic)

---

## Requirements

### REQ-BK-001: Bookmark Creation

**Description**: Users SHALL be able to create bookmarks with a URL, title, and optional description.

**Acceptance Criteria**:
1. The system MUST validate that a URL is provided
2. The system MUST validate that a title is provided
3. The system MUST validate that the URL is a valid HTTP or HTTPS URL
4. The system MUST automatically generate a unique 6-character short code
5. The system MUST normalise URLs by adding `https://` if no protocol is provided
6. The system SHALL associate the bookmark with the authenticated user
7. The system SHOULD allow setting public/private visibility

### REQ-BK-002: Short Code Generation

**Description**: Each bookmark SHALL have a unique short code for URL sharing.

**Acceptance Criteria**:
1. Short codes MUST be 6 alphanumeric characters
2. Short codes MUST be unique across all bookmarks
3. The system MUST detect and retry on collision
4. Short codes SHALL be generated automatically on creation
5. Short codes MUST NOT change after creation

### REQ-BK-003: Tag Management

**Description**: Users SHALL be able to organise bookmarks using tags.

**Acceptance Criteria**:
1. Users MUST be able to add multiple tags to a bookmark
2. Tags MUST be normalised to lowercase
3. The system MUST support comma-separated tag input
4. The system SHALL reuse existing tags where possible
5. Users SHOULD be able to filter bookmarks by tag
6. The tag list MUST be displayed as comma-separated values

### REQ-BK-004: Public/Private Visibility

**Description**: Users SHALL be able to control bookmark visibility.

**Acceptance Criteria**:
1. Bookmarks MUST default to private (is_public: false)
2. Public bookmarks SHALL be visible to unauthenticated users
3. Private bookmarks MUST only be visible to the owner
4. Users MUST be able to toggle visibility when editing
5. The public bookmark directory MUST only show public bookmarks

### REQ-BK-005: Short URL Redirection

**Description**: Users SHALL be able to share bookmarks via short URLs.

**Acceptance Criteria**:
1. The short URL format MUST be `/x/:short_code`
2. Accessing a short URL MUST redirect to the bookmarked URL
3. The system MUST validate the URL before redirecting
4. Only HTTP and HTTPS protocols SHALL be allowed for redirect
5. Invalid short codes MUST display an error message
6. Invalid URLs MUST display an error message

### REQ-BK-006: Search and Filter

**Description**: Users SHALL be able to search and filter their bookmarks.

**Acceptance Criteria**:
1. Users MUST be able to search by title, description, or URL
2. Search MUST be case-insensitive (ILIKE)
3. Users MUST be able to filter by tag
4. Search and tag filter SHOULD be combinable
5. Results MUST be ordered by creation date (newest first by default)
6. Users SHOULD be able to sort by oldest first

### REQ-BK-007: Bookmarklet Support

**Description**: The system SHALL provide a browser bookmarklet for quick saving.

**Acceptance Criteria**:
1. The bookmarklet MUST pre-fill the URL from the current page
2. The bookmarklet MUST pre-fill the title from the page title
3. The bookmarklet SHOULD capture selected text as description
4. The bookmarklet MUST redirect to the new bookmark form

### REQ-BK-008: API Support

**Description**: Bookmarks SHALL be accessible via JSON API.

**Acceptance Criteria**:
1. The index action MUST support JSON response format
2. The show action MUST support JSON response format
3. The create action MUST support JSON response format
4. The update action MUST support JSON response format
5. Error responses MUST include validation error messages
6. API responses MUST include bookmark attributes and tags

---

## Scenarios

### Scenario: Creating a Bookmark via Web Form

**Given** an authenticated user on the new bookmark page
**When** the user enters a valid URL, title, and tags
**And** clicks save
**Then** the system SHALL create the bookmark
**And** generate a unique short code
**And** redirect to the bookmarks index with a success message

### Scenario: Creating a Bookmark with Missing Protocol

**Given** an authenticated user creating a bookmark
**When** the user enters "example.com" as the URL
**Then** the system SHALL normalise it to "https://example.com"
**And** save the bookmark successfully

### Scenario: Accessing a Public Bookmark Short URL

**Given** a public bookmark with short code "abc123"
**When** an unauthenticated user visits `/x/abc123`
**Then** the system SHALL redirect to the bookmarked URL

### Scenario: Accessing a Private Bookmark via Index

**Given** a private bookmark owned by User A
**When** an unauthenticated user views the bookmarks index
**Then** the private bookmark SHALL NOT be displayed

### Scenario: Filtering Bookmarks by Tag

**Given** an authenticated user with bookmarks tagged "rails" and "javascript"
**When** the user filters by tag "rails"
**Then** only bookmarks with the "rails" tag SHALL be displayed

### Scenario: Creating a Bookmark with Duplicate URL

**Given** an authenticated user with an existing bookmark for "https://example.com"
**When** the user creates another bookmark for the same URL
**Then** the system SHALL allow the duplicate
**And** generate a unique short code for the new bookmark

### Scenario: Invalid URL Rejection

**Given** an authenticated user on the new bookmark page
**When** the user enters "not-a-valid-url" as the URL
**Then** the system SHALL display a validation error
**And** NOT create the bookmark

### Scenario: Short Code Collision Handling

**Given** a bookmark with short code "abc123" already exists
**When** a new bookmark is created
**And** the random generator produces "abc123"
**Then** the system SHALL generate a new short code
**And** retry until a unique code is found

### Scenario: Using the Bookmarklet

**Given** a user on any web page
**When** the user clicks the Jotter bookmarklet
**Then** the browser SHALL navigate to the new bookmark form
**And** the URL field SHALL be pre-filled with the current page URL
**And** the title field SHALL be pre-filled with the page title
