# Seed data for Nightlife Venue Verification Platform
# Venue admin role is assigned directly in the DB — both admins and customers are Users.

puts "Creating seed data..."

# Create venue admin users (role assigned here to simulate DB assignment)
admin1 = User.find_or_create_by!(phone_number: "+995591000001") do |u|
  u.first_name = "John"
  u.last_name  = "Smith"
  u.phone_verified = true
  u.role = "venue_admin"
end
puts "Created venue admin: #{admin1.full_name} (#{admin1.phone_number})"

admin2 = User.find_or_create_by!(phone_number: "+995591000002") do |u|
  u.first_name = "Sarah"
  u.last_name  = "Johnson"
  u.phone_verified = true
  u.role = "venue_admin"
end
puts "Created venue admin: #{admin2.full_name} (#{admin2.phone_number})"

# Create venues owned by the venue admin users
venue1 = Venue.find_or_create_by!(name: "Sky Bar", user: admin1) do |venue|
  venue.description = "Rooftop bar with stunning city views"
  venue.address     = "123 Main Street, 20th Floor"
end
puts "Created venue: #{venue1.name}"

venue2 = Venue.find_or_create_by!(name: "Neon Club", user: admin2) do |venue|
  venue.description = "Underground electronic music venue"
  venue.address     = "456 Dance Avenue"
end
puts "Created venue: #{venue2.name}"

# Create events
Event.find_or_create_by!(name: "Friday Night Live", venue: venue1) do |event|
  event.description          = "Live DJ performance every Friday"
  event.date_time            = 3.days.from_now.change(hour: 21)
  event.allow_global_approval = true
end

Event.find_or_create_by!(name: "VIP Saturday", venue: venue1) do |event|
  event.description          = "Exclusive Saturday night event"
  event.date_time            = 4.days.from_now.change(hour: 22)
  event.allow_global_approval = false
end

Event.find_or_create_by!(name: "Techno Tuesday", venue: venue2) do |event|
  event.description          = "Weekly techno night"
  event.date_time            = 5.days.from_now.change(hour: 23)
  event.allow_global_approval = true
end

Event.find_or_create_by!(name: "Private Launch Party", venue: venue2) do |event|
  event.description          = "Exclusive product launch"
  event.date_time            = 7.days.from_now.change(hour: 20)
  event.allow_global_approval = false
end

puts "Created events"

# Create a test customer
customer = User.find_or_create_by!(phone_number: "+995599123456") do |u|
  u.first_name = "Test"
  u.last_name  = "User"
  u.phone_verified = true
  u.role = "customer"
end
puts "Created test customer: #{customer.full_name}"

puts "\nSeed data created successfully!"
puts "\nVenue Admin phone numbers (log in with OTP):"
puts "  #{admin1.full_name}: #{admin1.phone_number}"
puts "  #{admin2.full_name}: #{admin2.phone_number}"
puts "\nCustomer phone: #{customer.phone_number}"
