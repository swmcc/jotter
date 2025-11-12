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

## Features

### Bookmarks ✅
- Save URLs with title and description
- Tag-based organisation
- Search and filter by tags
- Public/private bookmark visibility
- Short URLs for easy sharing (`/x/<short_code>`)
- Browser bookmarklet for one-click saving
- Public bookmark directory
- Clean, responsive interface

### Images (Coming Soon)
- Upload images with drag-and-drop
- Generate short, unique URLs for sharing
- Tag images for organisation
- Public/private image visibility
- Image optimisation and resizing

## Browser Bookmarklet

Save any webpage to your Jotter with one click!

### Installation

1. **Show your bookmarks bar** (if hidden):
   - Chrome/Edge: Press `Ctrl+Shift+B` (Windows) or `Cmd+Shift+B` (Mac)
   - Firefox: Press `Ctrl+Shift+B` (Windows) or `Cmd+Shift+B` (Mac)

2. **Create a new bookmark**:
   - Right-click your bookmarks bar
   - Select "Add page..." or "Add bookmark"
   - Name: `Add to Jotter` (or whatever you prefer)
   - URL: Paste the code below

3. **Bookmarklet code**:
```javascript
javascript:(function(){var url=encodeURIComponent(window.location.href);var title=encodeURIComponent(document.title);var desc=encodeURIComponent(window.getSelection().toString().substring(0,500));window.location.href='http://localhost:3000/bookmarks/new?url='+url+'&title='+title+'&description='+desc;})();
```

4. **Usage**:
   - Browse to any webpage you want to save
   - Optionally select text to use as the description
   - Click the "Add to Jotter" bookmark
   - The form will open pre-filled with the page details
   - Add tags and save!

**Note**: Replace `http://localhost:3000` with your actual Jotter URL in production.

## Contributing

Feel free to submit pull requests or create issues if you find any bugs or have suggestions for improvements.

## Licence

This project is intended for personal use. If you'd like to use it yourself, feel free to fork this repository.
