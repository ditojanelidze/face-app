# Seed data for Nightlife Venue Verification Platform

puts "Creating seed data..."

# Create Venue Admins
admin1 = VenueAdmin.find_or_create_by!(email: "admin@skybar.com") do |admin|
  admin.password = "password123"
  admin.first_name = "John"
  admin.last_name = "Smith"
end
puts "Created venue admin: #{admin1.email}"

admin2 = VenueAdmin.find_or_create_by!(email: "admin@neonclub.com") do |admin|
  admin.password = "password123"
  admin.first_name = "Sarah"
  admin.last_name = "Johnson"
end
puts "Created venue admin: #{admin2.email}"

# Create Venues
venue1 = Venue.find_or_create_by!(name: "Sky Bar", venue_admin: admin1) do |venue|
  venue.description = "Rooftop bar with stunning city views"
  venue.address = "123 Main Street, 20th Floor"
end
puts "Created venue: #{venue1.name}"

venue2 = Venue.find_or_create_by!(name: "Neon Club", venue_admin: admin2) do |venue|
  venue.description = "Underground electronic music venue"
  venue.address = "456 Dance Avenue"
end
puts "Created venue: #{venue2.name}"

# Create Events
Event.find_or_create_by!(name: "Friday Night Live", venue: venue1) do |event|
  event.description = "Live DJ performance every Friday"
  event.date_time = 3.days.from_now.change(hour: 21)
  event.allow_global_approval = true
end

Event.find_or_create_by!(name: "VIP Saturday", venue: venue1) do |event|
  event.description = "Exclusive Saturday night event"
  event.date_time = 4.days.from_now.change(hour: 22)
  event.allow_global_approval = false
end

Event.find_or_create_by!(name: "Techno Tuesday", venue: venue2) do |event|
  event.description = "Weekly techno night"
  event.date_time = 5.days.from_now.change(hour: 23)
  event.allow_global_approval = true
end

Event.find_or_create_by!(name: "Private Launch Party", venue: venue2) do |event|
  event.description = "Exclusive product launch"
  event.date_time = 7.days.from_now.change(hour: 20)
  event.allow_global_approval = false
end

puts "Created events"

# Create a test user
user = User.find_or_create_by!(phone_number: "+15551234567") do |u|
  u.first_name = "Test"
  u.last_name = "User"
  u.phone_verified = true
end
puts "Created test user: #{user.full_name}"

puts "\nSeed data created successfully!"
puts "\nVenue Admin Credentials:"
puts "  Email: admin@skybar.com | Password: password123"
puts "  Email: admin@neonclub.com | Password: password123"
puts "\nTest User Phone: +15551234567"
