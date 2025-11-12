# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create default user
User.find_or_create_by!(email_address: "me@swm.cc") do |user|
  user.password = "password5"
  user.password_confirmation = "password5"
end

puts "✅ Seeded default user: me@swm.cc"
