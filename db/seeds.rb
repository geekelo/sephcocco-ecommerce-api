# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# db/seeds/sephcocco_user_roles.rb

roles = %w[user manager frontdesk superadmin admin support]

roles.each do |role_name|
  SephcoccoUserRole.find_or_create_by!(name: role_name)
end

puts "✅ CLA ROLES ADDED SUCCESSFULLY"


# db/seeds/sephcocco_users.rb

puts "🌟 Seeding Sephcocco Users for each role..."

roles = %w[user manager frontdesk superadmin admin support]

roles.each do |role_name|
  role = SephcoccoUserRole.find_by(name: role_name)

  if role.nil?
    puts "❗ Role '#{role_name}' not found. Skipping user creation for this role."
    next
  end

  email = "#{role_name}@sephcocco.com"

  user = SephcoccoUser.find_or_create_by!(email: email) do |u|
    u.name = "#{role_name.capitalize} User"
    u.address = "123 #{role_name.capitalize} Street"
    u.phone_number = "080#{rand(10000000..99999999)}"
    u.whatsapp_number = "080#{rand(10000000..99999999)}"
    u.sephcocco_user_role_id = role.id
  end

  puts "✅ Created/Found user for role: #{role_name} (Email: #{user.email})"
end

  email2 = "admin2@sephcocco.com"
  role2 = SephcoccoUserRole.find_by(name: "admin")

  user2 = SephcoccoUser.find_or_create_by!(email: email2) do |u|
    u.name = "Admin2 User"
    u.address = "123 Admin2 Street"
    u.phone_number = "080#{rand(10000000..99999999)}"
    u.whatsapp_number = "080#{rand(10000000..99999999)}"
    u.sephcocco_user_role_id = role.id
    u.password = "1234567" # Ensure password is set for the user
    u.password_confirmation = "1234567" # Ensure password confirmation matches
  end

  puts "✅ Created/Found user for role: \"admin\" (Email2: #{user2.email})"
unless user2.persisted?
  puts "❗ Failed to create user for role: \"admin\" (Email2: #{user2.email})"
end

puts "🎉 Sephcocco Users seeded successfully!"
