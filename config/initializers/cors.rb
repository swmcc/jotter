# Configure CORS for native app API access
#
# This allows the macOS and iOS Jotter apps to make requests to the upload API.
# Since native apps don't send an Origin header in the same way browsers do,
# we're permissive here. Authentication is handled via Bearer tokens.

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Allow requests from any origin (native apps don't have a web origin)
    origins "*"

    # Only allow the upload endpoint for API access
    resource "/u",
      headers: :any,
      methods: [ :post, :options ],
      expose: [ "Authorization" ],
      max_age: 600

    resource "/u.json",
      headers: :any,
      methods: [ :post, :options ],
      expose: [ "Authorization" ],
      max_age: 600
  end
end
