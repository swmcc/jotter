# Jotter - Project Conventions

## Overview

Jotter is a personal content management application for managing and sharing two types of content:

1. **Bookmarks** - Save and organise web links with tags, descriptions, and short URLs for sharing (Delicious-style)
2. **Photos** - Upload and share images via unique, short URLs organised in galleries and albums

The application solves the problem of volatile URLs from third-party services and provides a self-hosted alternative to services like Delicious for bookmarks and unreliable image hosting platforms.

## Tech Stack

| Component | Technology |
|-----------|------------|
| **Language** | Ruby 3.3.0 |
| **Framework** | Rails 8.0.4 |
| **Database** | PostgreSQL |
| **Authentication** | Rails 8 built-in authentication (has_secure_password) |
| **Frontend** | Hotwire (Turbo + Stimulus) with Importmap |
| **Styling** | Tailwind CSS v4 |
| **File Storage** | Active Storage (AWS S3 for production) |
| **Background Jobs** | Solid Queue |
| **Caching** | Solid Cache |
| **Asset Pipeline** | Propshaft |
| **Testing** | RSpec with FactoryBot |
| **Linting** | RuboCop (Rails Omakase) |
| **Security Scanning** | Brakeman |
| **Deployment** | Kamal with Docker |

## Architecture

### Domain Model

```
User
  has_many :sessions
  has_many :api_tokens
  has_many :bookmarks
  has_many :galleries
  has_many :albums
  has_many :photos

Bookmark
  belongs_to :user
  has_many :tags (through taggings, polymorphic)
  - title, url, description, short_code, is_public

Gallery
  belongs_to :user
  has_many :albums
  has_many :tags (through taggings, polymorphic)
  - title, description, short_code, is_public, cover_photo_id

Album
  belongs_to :user
  belongs_to :gallery (optional)
  has_many :photos
  has_many :tags (through taggings, polymorphic)
  - title, description, short_code, is_public, cover_photo_id

Photo
  belongs_to :user
  belongs_to :album (optional)
  has_one_attached :image
  has_many :tags (through taggings, polymorphic)
  - title, description, short_code, is_public

Tag
  has_many :taggings
  - name (normalised to lowercase)

Tagging (polymorphic join)
  belongs_to :tag
  belongs_to :taggable (Bookmark, Gallery, Album, Photo)
```

### URL Structure

| Route | Purpose |
|-------|---------|
| `/` | Home page |
| `/session` | Authentication (login/logout) |
| `/bookmarks` | Bookmark management |
| `/galleries` | Gallery management |
| `/albums` | Album management |
| `/photos` | Photo management |
| `/u` | Quick upload interface |
| `/x/:short_code` | Short URL redirect for bookmarks |
| `/c/:short_code` | Short URL for media (photos, albums, galleries) |
| `/dashboard` | User dashboard |
| `/api_tokens` | API token management |

### Short URL System

All content types use 6-character alphanumeric short codes:
- Bookmarks: `/x/:short_code` redirects to the original URL
- Photos: `/c/:short_code` serves the image directly
- Albums/Galleries: `/c/:short_code` redirects to the show page

## Git Commit Conventions

Use [Gitmoji](https://gitmoji.dev/) format for commit messages:

| Emoji | Code | Usage |
|-------|------|-------|
| :sparkles: | `:sparkles:` | New feature |
| :bug: | `:bug:` | Bug fix |
| :recycle: | `:recycle:` | Refactoring |
| :lipstick: | `:lipstick:` | UI/styling changes |
| :zap: | `:zap:` | Performance improvement |
| :memo: | `:memo:` | Documentation |
| :white_check_mark: | `:white_check_mark:` | Add/update tests |
| :lock: | `:lock:` | Security fix |
| :art: | `:art:` | Code structure/format |
| :fire: | `:fire:` | Remove code/files |
| :wastebasket: | `:wastebasket:` | Deprecate code |
| :construction: | `:construction:` | Work in progress |
| :truck: | `:truck:` | Move/rename files |
| :wrench: | `:wrench:` | Configuration changes |
| :heavy_plus_sign: | `:heavy_plus_sign:` | Add dependency |
| :heavy_minus_sign: | `:heavy_minus_sign:` | Remove dependency |
| :arrow_up: | `:arrow_up:` | Upgrade dependency |
| :rotating_light: | `:rotating_light:` | Fix linter warnings |
| :see_no_evil: | `:see_no_evil:` | Add/update .gitignore |
| :card_file_box: | `:card_file_box:` | Database changes |
| :globe_with_meridians: | `:globe_with_meridians:` | Internationalisation |

**Format**: `:emoji: Brief description`

**Examples**:
- `:sparkles: Add tag autocomplete for bookmarks`
- `:bug: Fix short URL collision detection`
- `:card_file_box: Add index on bookmarks.short_code`

## Code Conventions

### Ruby/Rails

- Follow RuboCop Rails Omakase style guide
- Use strong parameters in controllers
- Use `Current` for request-local storage (authentication context)
- Prefer scopes for common queries
- Use concerns for shared model behaviour

### Controllers

- Use `allow_unauthenticated_access` for public endpoints
- Follow RESTful conventions
- Support both HTML and JSON responses where appropriate
- Use `Current.session.user` for authenticated user

### Models

- Validate presence and uniqueness of `short_code`
- Use `before_validation` callbacks for generating short codes
- Normalise data (lowercase tags, normalise URLs)
- Use polymorphic associations for tagging

### Views

- Use Tailwind CSS utility classes
- Prefer Turbo Frames for partial page updates
- Use partials for reusable components

### Testing

- Use RSpec for unit and request specs
- Use FactoryBot for test data
- Organise specs by type: `spec/models/`, `spec/requests/`

## Commands

### Development

```bash
# Start development server (with Tailwind watching)
bin/dev

# Start Rails server only
rails server

# Rails console
rails console

# Install dependencies
bundle install
```

### Database

```bash
# Create database
rails db:create

# Run migrations
rails db:migrate

# Seed database
rails db:seed

# Reset database (drop, create, migrate, seed)
rails db:reset
```

### Testing

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/bookmark_spec.rb

# Run tests matching pattern
bundle exec rspec --pattern "**/bookmarks*"
```

### Linting & Security

```bash
# Run RuboCop
bundle exec rubocop

# Auto-fix RuboCop issues
bundle exec rubocop -A

# Run Brakeman security scan
bin/brakeman --no-pager
```

### Makefile Shortcuts

```bash
make local.run      # Run development server
make local.setup    # Full setup (install, db, seed)
make local.test     # Run RSpec tests
make lint           # Run RuboCop
make lint.fix       # Auto-fix RuboCop issues
make console        # Rails console
make help           # Show all targets
```

## Environment Variables

| Variable | Purpose |
|----------|---------|
| `DATABASE_URL` | PostgreSQL connection string |
| `SECRET_KEY_BASE` | Rails secret key |
| `AWS_ACCESS_KEY_ID` | AWS S3 credentials (production) |
| `AWS_SECRET_ACCESS_KEY` | AWS S3 credentials (production) |
| `AWS_REGION` | AWS region |
| `AWS_BUCKET` | S3 bucket name |
