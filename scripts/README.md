# Jotter Upload Scripts

Command-line and GUI tools for uploading images to Jotter.

## Quick Start

1. **Configure credentials** - Copy the example config:
   ```bash
   cp scripts/jotter-config.example ~/.jotter-config
   ```
   Then edit `~/.jotter-config` with your server URL and API token.

2. **Generate an API token** in Jotter at `/api_tokens`

## Tools

### `jotter-upload` (Command Line)

Upload images from the terminal:

```bash
# Single file
./scripts/jotter-upload screenshot.png

# Multiple files
./scripts/jotter-upload *.png

# From anywhere (add to PATH)
ln -s "$(pwd)/scripts/jotter-upload" /usr/local/bin/jotter-upload
jotter-upload ~/Desktop/photo.jpg
```

Features:
- Uploads to your "Uploads" album
- Copies short URL to clipboard automatically
- Shows macOS notification with result
- Supports JPEG, PNG, GIF, and WebP

### `Jotter Upload.app` (Dock Droplet)

A macOS app you can keep in your dock. Drag images onto it to upload.

**Setup:**
1. Copy `Jotter Upload.app` to `/Applications` or keep it in this folder
2. Drag it to your dock
3. Drag images onto the dock icon to upload

The app uses the same `~/.jotter-config` file and the `jotter-upload` script.

## Configuration

Create `~/.jotter-config`:

```bash
JOTTER_SERVER_URL="https://your-jotter-server.com"
JOTTER_API_TOKEN="your-token-here"
```

## API Response

Successful uploads return:

```json
{
  "photo": {
    "id": 123,
    "short_code": "abc123",
    "short_url": "https://your-server.com/c/abc123",
    "title": "Screenshot 2024-01-25",
    "created_at": "2024-01-25T10:30:00Z"
  }
}
```

## Troubleshooting

**"Cannot find jotter-upload script"**
- Ensure `jotter-upload` is in the same folder as `Jotter Upload.app`
- Or add it to your PATH

**"Not Configured"**
- Create `~/.jotter-config` with your credentials

**Upload fails with 401**
- Check your API token is correct
- Generate a new token at `/api_tokens`

**Upload fails with 422**
- File might not be a valid image
- File might exceed 10MB limit
