puts "Cleaning DB..."
Doctor.destroy_all

puts "Creating Doctors..."
doc1 = Doctor.create!(first_name: "Gregory", last_name: "House", specialty: "Diagnostics", is_active: true)
doc2 = Doctor.create!(first_name: "Meredith", last_name: "Grey", specialty: "General Surgery", is_active: true)
doc3 = Doctor.create!(first_name: "Stephen", last_name: "Strange", specialty: "Neurosurgery", is_active: true)

puts "Creating Schedules for the next 7 days (9am - 5pm)..."
(0..7).each do |i|
  date = Date.today + i.days
  [doc1, doc2, doc3].each do |doc|
    # Exclude weekends randomly or just keep it simple, let's keep it simple
    next if date.saturday? || date.sunday?
    
    Schedule.create!(
      doctor: doc,
      date: date,
      start_time: Time.zone.parse("09:00:00"),
      end_time: Time.zone.parse("17:00:00")
    )
  end
end

puts "Done! Seeded 3 doctors and their schedules."
