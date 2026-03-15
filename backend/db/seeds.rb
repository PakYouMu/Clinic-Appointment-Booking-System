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
