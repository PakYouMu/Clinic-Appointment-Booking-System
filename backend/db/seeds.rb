puts "Seeding Users..."
client_user = User.find_or_create_by!(email: "client@mustard.com") do |u|
  u.password = "password123"
  u.role = :patient
  u.phone_number = "+63 912 345 6789"
end

User.find_or_create_by!(email: "admin@mustard.com") do |u|
  u.password = "password123"
  u.role = :admin
end

# Create a patient profile for the client user
Patient.find_or_create_by!(user: client_user) do |p|
  p.first_name = "Demo"
  p.last_name = "Patient"
  p.phone_number = "+63 912 345 6789"
end

puts "Seeding Doctors..."
doc1 = Doctor.find_or_create_by!(first_name: "Gregory", last_name: "House") do |d|
  d.specialty = "Diagnostics"
  d.is_active = true
end

doc2 = Doctor.find_or_create_by!(first_name: "Meredith", last_name: "Grey") do |d|
  d.specialty = "General Surgery"
  d.is_active = true
end

doc3 = Doctor.find_or_create_by!(first_name: "Stephen", last_name: "Strange") do |d|
  d.specialty = "Neurosurgery"
  d.is_active = true
end

puts "Seeding Schedules for the next 7 days..."
(0..7).each do |i|
  date = Date.today + i.days
  next if date.saturday? || date.sunday?
  
  [doc1, doc2, doc3].each do |doc|
    Schedule.find_or_create_by!(
      doctor: doc,
      date: date,
      start_time: Time.zone.parse("09:00:00"),
      end_time: Time.zone.parse("17:00:00")
    )
  end
end

puts "Done! Idempotent seeding complete."
