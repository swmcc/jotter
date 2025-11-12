# Jotter

Jotter is a Ruby on Rails application for managing and sharing two types of content:

1. **Images** - Upload and share images via unique, short URLs
2. **Bookmarks** - Save and organise web links with tags and descriptions

Built for personal use to solve the problem of volatile URLs from third-party services and to provide a self-hosted alternative to services like Delicious.

## Why Jotter?

Corporate communication tools and third-party bookmark services can be unreliable:

- Image URLs shared through services like Microsoft Teams can be problematic due to security software and firewall rules
- Third-party bookmark services often change, sunset, or disappear, taking your links with them
- Self-hosting ensures your content and URLs remain stable and accessible long-term

## Tech Stack

- **Ruby** 3.3.0
- **Rails** 8.0.4
- **Database** PostgreSQL
- **Authentication** Rails 8 built-in authentication
- **Frontend** Hotwire (Turbo + Stimulus) with Importmap
- **Styling** Tailwind CSS v4
- **Deployment** Kamal-ready with Docker

## Getting Started

### Prerequisites

- Ruby 3.3.0
- PostgreSQL
- Bundler

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd jotter

# Install dependencies
bundle install

# Set up the database
rails db:create db:migrate

# Start the development server
bin/dev
```

The application will be available at `http://localhost:3000`

## Development

```bash
# Run the development server with Tailwind watching
bin/dev

# Run Rails console
rails console

# Run migrations
rails db:migrate

# Reset database
rails db:reset
```

## Features (Planned)

### Images
- Upload images with drag-and-drop
- Generate short, unique URLs for sharing
- Tag images for organisation
- Public/private image visibility
- Image optimisation and resizing

### Bookmarks
- Save URLs with title and description
- Tag-based organisation
- Search and filter by tags
- Public/private bookmark visibility
- Automatic metadata extraction (page title, description)
- Export bookmarks in standard formats

### Shared
- Unified short URL system
- Cross-content search
- Clean, minimal public pages
- Modern, responsive interface

## Contributing

Feel free to submit pull requests or create issues if you find any bugs or have suggestions for improvements.

## Licence

This project is intended for personal use. If you'd like to use it yourself, feel free to fork this repository.
