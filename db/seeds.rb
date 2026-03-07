# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

if Rails.env.development?
  user = User.find_or_initialize_by(email: "test@mail.com")
  if user.new_record? || user.invited?
    user.password = "password123"
    user.password_confirmation = "password123"
    user.name = "Test User"
    user.save!
    Cellars::ProvisionDefaultCellar.call(user: user) unless user.cellar_memberships.exists?(role: :owner)
    puts "Seeded test user: test@mail.com / password123"
  else
    puts "Test user already exists: test@mail.com"
  end
end
