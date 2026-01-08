# Photos Domain Specification

## Overview

The Photos domain provides image upload, organisation, and sharing functionality. Photos are organised into Albums, which can be grouped into Galleries. All content types support tagging and short URLs for easy sharing.

## Data Models

### Gallery

| Field | Type | Constraints |
|-------|------|-------------|
| `id` | bigint | Primary key |
| `user_id` | bigint | Foreign key, NOT NULL |
| `title` | string | NOT NULL |
| `description` | text | Optional |
| `short_code` | string | NOT NULL, UNIQUE, 6 alphanumeric chars |
| `is_public` | boolean | NOT NULL, default: false |
| `cover_photo_id` | integer | Optional |
| `created_at` | datetime | NOT NULL |
| `updated_at` | datetime | NOT NULL |

### Album

| Field | Type | Constraints |
|-------|------|-------------|
| `id` | bigint | Primary key |
| `user_id` | bigint | Foreign key, NOT NULL |
| `gallery_id` | bigint | Foreign key, optional |
| `title` | string | NOT NULL |
| `description` | text | Optional |
| `short_code` | string | NOT NULL, UNIQUE, 6 alphanumeric chars |
| `is_public` | boolean | NOT NULL, default: false |
| `cover_photo_id` | integer | Optional |
| `created_at` | datetime | NOT NULL |
| `updated_at` | datetime | NOT NULL |

### Photo

| Field | Type | Constraints |
|-------|------|-------------|
| `id` | bigint | Primary key |
| `user_id` | bigint | Foreign key, NOT NULL |
| `album_id` | bigint | Foreign key, optional |
| `title` | string | NOT NULL |
| `description` | text | Optional |
| `short_code` | string | NOT NULL, UNIQUE, 6 alphanumeric chars |
| `is_public` | boolean | NOT NULL, default: false |
| `created_at` | datetime | NOT NULL |
| `updated_at` | datetime | NOT NULL |

### Associations

```
Gallery
  BELONGS TO User
  HAS MANY Albums
  HAS MANY Tags (through Taggings)

Album
  BELONGS TO User
  BELONGS TO Gallery (optional)
  HAS MANY Photos
  HAS MANY Tags (through Taggings)

Photo
  BELONGS TO User
  BELONGS TO Album (optional)
  HAS ONE ATTACHED Image (Active Storage)
  HAS MANY Tags (through Taggings)
```

---

## Requirements

### REQ-PH-001: Photo Upload

**Description**: Users SHALL be able to upload images.

**Acceptance Criteria**:
1. Users MUST be able to upload JPEG, PNG, GIF, and WebP images
2. The system MUST validate file type (content type check)
3. The system MUST enforce a maximum file size of 10MB
4. The system MUST require a title (auto-generated from filename if not provided)
5. The system MUST generate a unique 6-character short code
6. The system SHALL associate uploaded photos with the authenticated user
7. Photos SHOULD be processable into variants (thumbnail, medium, large)

### REQ-PH-002: Image Variants

**Description**: The system SHALL generate multiple image sizes for display optimisation.

**Acceptance Criteria**:
1. Thumbnail variant MUST be limited to 200x200 pixels
2. Medium variant MUST be limited to 800x800 pixels
3. Large variant MUST be limited to 1600x1600 pixels
4. Variants MUST maintain aspect ratio (resize_to_limit)
5. Variant generation SHALL occur in a background job

### REQ-PH-003: Album Organisation

**Description**: Users SHALL be able to organise photos into albums.

**Acceptance Criteria**:
1. Albums MUST have a title
2. Albums MAY have a description
3. Albums MAY belong to a Gallery (optional)
4. Albums MUST have a unique short code
5. Albums SHOULD support a cover photo
6. Cover photo MUST fall back to first photo in album if not set
7. Albums MUST support public/private visibility

### REQ-PH-004: Gallery Organisation

**Description**: Users SHALL be able to group albums into galleries.

**Acceptance Criteria**:
1. Galleries MUST have a title
2. Galleries MAY have a description
3. Galleries MUST have a unique short code
4. Galleries SHOULD support a cover photo
5. Cover photo MUST fall back to first photo from first album if not set
6. Galleries MUST support public/private visibility

### REQ-PH-005: Short URL Sharing

**Description**: Users SHALL be able to share photos via short URLs.

**Acceptance Criteria**:
1. Photo short URLs MUST use format `/c/:short_code`
2. Album short URLs MUST use format `/c/:short_code`
3. Gallery short URLs MUST use format `/c/:short_code`
4. Photo short URLs MUST serve the image directly (inline disposition)
5. Album/Gallery short URLs MUST redirect to their show pages
6. Invalid short codes MUST display an error message

### REQ-PH-006: Quick Upload

**Description**: Users SHALL have a streamlined interface for quick photo uploads.

**Acceptance Criteria**:
1. Quick upload interface MUST be available at `/u`
2. Quick uploads MUST go to an auto-created "Uploads" album
3. The "Uploads" album MUST be created automatically if it doesn't exist
4. The "Uploads" album MUST default to private
5. Title SHOULD auto-generate from filename if not provided
6. Users MUST be able to view their uploads at `/u/view`

### REQ-PH-007: Public/Private Visibility

**Description**: Users SHALL be able to control visibility of photos, albums, and galleries.

**Acceptance Criteria**:
1. All content MUST default to private (is_public: false)
2. Public content SHALL be visible to unauthenticated users
3. Private content MUST only be visible to the owner
4. Users MUST be able to toggle visibility when editing
5. Public index pages MUST only show public content to unauthenticated users

### REQ-PH-008: Tag Support

**Description**: Photos, albums, and galleries SHALL support tagging.

**Acceptance Criteria**:
1. All content types MUST support multiple tags
2. Tags MUST be normalised to lowercase
3. Tags MUST use the polymorphic Tagging association
4. Users SHOULD be able to filter by tag
5. Tag input MUST accept comma-separated values

### REQ-PH-009: Search and Filter

**Description**: Users SHALL be able to search and filter photos.

**Acceptance Criteria**:
1. Users MUST be able to search by title and description
2. Search MUST be case-insensitive (ILIKE)
3. Users MUST be able to filter by tag
4. Results MUST be ordered by creation date (newest first)

### REQ-PH-010: Background Processing

**Description**: Image processing SHALL occur in background jobs.

**Acceptance Criteria**:
1. Variant generation MUST be queued as a background job
2. The ProcessPhotoJob MUST accept a photo ID
3. Users SHOULD see a message indicating processing is in progress
4. The system MUST handle job failures gracefully

---

## Scenarios

### Scenario: Uploading a Photo to an Album

**Given** an authenticated user viewing an album
**When** the user uploads a valid JPEG image with a title
**Then** the system SHALL create the photo record
**And** attach the image via Active Storage
**And** generate a unique short code
**And** queue background processing for variants
**And** redirect to the album with a success message

### Scenario: Quick Upload

**Given** an authenticated user at `/u`
**When** the user uploads an image without specifying a title
**Then** the system SHALL create an "Uploads" album if it doesn't exist
**And** auto-generate a title from the filename
**And** associate the photo with the "Uploads" album
**And** redirect to `/u/view` with a success message

### Scenario: Accessing Photo via Short URL

**Given** a public photo with short code "xyz789"
**When** any user visits `/c/xyz789`
**Then** the system SHALL serve the image directly
**And** use inline disposition for browser display

### Scenario: Accessing Album via Short URL

**Given** a public album with short code "abc123"
**When** any user visits `/c/abc123`
**Then** the system SHALL redirect to the album show page

### Scenario: Uploading Oversized Image

**Given** an authenticated user uploading a photo
**When** the image file exceeds 10MB
**Then** the system SHALL display a validation error
**And** NOT create the photo record

### Scenario: Uploading Invalid File Type

**Given** an authenticated user uploading a file
**When** the file is a PDF (not an image)
**Then** the system SHALL display a validation error
**And** NOT create the photo record

### Scenario: Creating a Gallery with Albums

**Given** an authenticated user
**When** the user creates a gallery
**And** adds albums to the gallery
**Then** the albums SHALL be associated with the gallery
**And** the gallery cover photo SHALL fall back to the first album's first photo

### Scenario: Viewing Private Photos as Anonymous User

**Given** private photos exist in the system
**When** an unauthenticated user views the photos index
**Then** only public photos SHALL be displayed
**And** private photos SHALL NOT be accessible

### Scenario: Setting Album Cover Photo

**Given** an album with multiple photos
**When** the user sets a specific photo as the cover
**Then** that photo SHALL be used as the album cover
**And** it SHALL override the default first-photo behaviour

### Scenario: Filtering Photos by Tag

**Given** photos tagged with "holiday" and "family"
**When** the user filters by tag "holiday"
**Then** only photos with the "holiday" tag SHALL be displayed
