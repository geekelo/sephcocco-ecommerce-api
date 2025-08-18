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

roles = %w[user manager frontdesk superadmin admin support rider]

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
    u.sephcocco_user_role_id = role2.id
    u.password = "1234567" # Ensure password is set for the user
    u.password_confirmation = "1234567" # Ensure password confirmation matches
  end

  puts "✅ Created/Found user for role: \"admin\" (Email2: #{user2.email})"
unless user2.persisted?
  puts "❗ Failed to create user for role: \"admin\" (Email2: #{user2.email})"
end

  email3 = "user2@sephcocco.com"
  role3 = SephcoccoUserRole.find_by(name: "user")

  user3 = SephcoccoUser.find_or_create_by!(email: email3) do |u|
    u.name = "User3 User"
    u.address = "123 User3 Street"
    u.phone_number = "080#{rand(10000000..99999999)}"
    u.whatsapp_number = "080#{rand(10000000..99999999)}"
    u.sephcocco_user_role_id = role3.id
    u.password = "1234567" # Ensure password is set for the user
    u.password_confirmation = "1234567" # Ensure password confirmation matches
  end

  puts "✅ Created/Found user for role: \"user\" (Email3: #{user3.email})"
unless user3.persisted?
  puts "❗ Failed to create user for role: \"user\" (Email3: #{user3.email})"
end

main_outlet = %w[restaurant lounge pharmacy]
outlets = main_outlet.map { |name| SephcoccoOutlet.find_or_create_by(name: name) }
puts "✅ Created/Found outlets: #{outlets.map(&:name).join(', ')}"


puts "🎉 Sephcocco Users seeded successfully!"

# db/seeds/faq_categories.rb

puts "📚 Seeding FAQ Categories for all outlets..."

# Create "all" FAQ category for Lounge
lounge_all_category = Lounge::SephcoccoLoungeFaqCategory.find_or_create_by!(title: "all") do |category|
  category.description = "General FAQ category for all lounge-related questions"
  category.visibility = true
  category.position = 1
end
puts "✅ Created/Found Lounge FAQ Category: #{lounge_all_category.title}"

# Create "all" FAQ category for Restaurant
restaurant_all_category = Restaurant::SephcoccoRestaurantFaqCategory.find_or_create_by!(title: "all") do |category|
  category.description = "General FAQ category for all restaurant-related questions"
  category.visibility = true
  category.position = 1
end
puts "✅ Created/Found Restaurant FAQ Category: #{restaurant_all_category.title}"

# Create "all" FAQ category for Pharmacy
pharmacy_all_category = Pharmacy::SephcoccoPharmacyFaqCategory.find_or_create_by!(title: "all") do |category|
  category.description = "General FAQ category for all pharmacy-related questions"
  category.visibility = true
  category.position = 1
end
puts "✅ Created/Found Pharmacy FAQ Category: #{pharmacy_all_category.title}"

puts "🎉 FAQ Categories seeded successfully!"
