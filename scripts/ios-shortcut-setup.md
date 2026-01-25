# iOS Shortcut for Jotter Uploads

Upload images from your iPhone/iPad to Jotter using the iOS Shortcuts app.

## Prerequisites

- iOS 14+ or iPadOS 14+
- Shortcuts app (pre-installed)
- Your Jotter API token (generate at `/api_tokens` in Jotter)

## Create the Shortcut

1. Open the **Shortcuts** app on your iPhone/iPad
2. Tap **+** to create a new shortcut
3. Add these actions in order:

---

### Action 1: Receive Input

Search for **"Receive"** and add **"Receive Input from Share Sheet"**

- Tap on **"Any"** and select only **"Images"**
- Leave "If there's no input" as **"Continue"**

---

### Action 2: Get Images

Search for **"Get Images"** and add **"Get Images from Input"**

- Input should automatically be set to **"Shortcut Input"**

---

### Action 3: Encode as Base64

Search for **"Base64"** and add **"Base64 Encode"**

- Input: **"Images"** (from previous step)

---

### Action 4: Build JSON Body

Search for **"Text"** and add a **"Text"** action

Enter this exactly (replace with your values):
```
{"image_base64":"[Base64 Encoded]"}
```

To insert the Base64 Encoded variable:
1. Delete the `[Base64 Encoded]` placeholder text
2. Tap where it was and select **"Base64 Encoded"** from variables

---

### Action 5: Upload to Jotter

Search for **"Get Contents"** and add **"Get Contents of URL"**

Configure it:
- **URL**: `https://YOUR-SERVER.com/u.json` (replace with your Jotter URL)
- Tap **"Show More"**
- **Method**: `POST`
- **Headers**: Add these two headers:
  - `Authorization` → `Bearer YOUR_API_TOKEN`
  - `Content-Type` → `application/json`
- **Request Body**: Select **"File"**
- **File**: Tap and select the **"Text"** variable from step 4

---

### Action 6: Extract Short URL

Search for **"Get Value"** and add **"Get Dictionary Value"**

- **Key**: `photo.short_url`
- **Dictionary**: **"Contents of URL"**

---

### Action 7: Copy to Clipboard

Search for **"Copy"** and add **"Copy to Clipboard"**

- Input: **"Dictionary Value"** (the short URL)

---

### Action 8: Show Notification

Search for **"Notification"** and add **"Show Notification"**

- Text: `Uploaded! [Dictionary Value]`

(Insert the Dictionary Value variable into the text)

---

## Configure the Shortcut

1. Tap the shortcut name at the top
2. Name it **"Jotter"** or **"Upload to Jotter"**
3. Tap the icon to choose a camera or photo icon
4. Tap the **ⓘ** info button at the bottom
5. Enable **"Show in Share Sheet"**
6. Tap **Done**

---

## Usage

1. Open **Photos**, **Safari**, or any app
2. Select an image and tap **Share**
3. Scroll down and tap **"Jotter"**
4. Wait for upload to complete
5. The short URL is now in your clipboard!

---

## Testing

Test with curl first to verify your server is working:

```bash
# Create a small test image
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==" > /tmp/test.b64

# Upload it
curl -X POST \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"image_base64":"'"$(cat /tmp/test.b64)"'","filename":"test.png"}' \
  https://YOUR-SERVER.com/u.json
```

---

## Troubleshooting

**"Couldn't communicate with a helper application"**
- Check your server URL is correct and uses HTTPS
- Try opening the URL in Safari first

**"Bad request" or 400 error**
- Make sure `Content-Type` header is exactly `application/json`
- Verify the JSON format in the Text action

**401 Unauthorized**
- Check your API token is correct
- Generate a new token at `/api_tokens`

**422 Unprocessable Entity**
- Image might be too large (max 10MB)
- Image format not supported (use JPEG, PNG, GIF, or WebP)

**Nothing happens after upload**
- Check if "Show Notification" action is present
- Try adding a "Show Result" action to debug

---

## Security Note

Your API token is stored within the shortcut. Do not share the shortcut file with others.

---

## Alternative: Share via Files App

If the share sheet approach doesn't work well, you can:

1. Save images to the Files app
2. Create a shortcut that:
   - Shows a file picker
   - Selects an image
   - Uploads it using the steps above
