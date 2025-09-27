# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create all daydream events
puts "Creating events from hardcoded list..."
event_names = [
  "daydream-abu-dhabi",
  "daydream-abu-hamad",
  "daydream-abuoka",
  "daydream-addis-ababa",
  "daydream-adelaide",
  "daydream-agadir",
  "daydream-al-qurna",
  "daydream-alexandria",
  "daydream-andover",
  "daydream-atfih",
  "daydream-atlanta",
  "daydream-auckland",
  "daydream-aurora",
  "daydream-austin",
  "daydream-barranquilla",
  "daydream-bengaluru",
  "daydream-bhagalpur",
  "daydream-biratnagar",
  "daydream-bogota",
  "daydream-boston",
  "daydream-braov",
  "daydream-brighton",
  "daydream-brisbane",
  "daydream-budapest",
  "daydream-bujumbura",
  "daydream-burlington",
  "daydream-butwal",
  "daydream-cairo",
  "daydream-calgary",
  "daydream-cambridge",
  "daydream-casablanca",
  "daydream-charlotte",
  "daydream-chitungwiza",
  "daydream-columbus",
  "daydream-dc",
  "daydream-dej",
  "daydream-delhi",
  "daydream-dfw",
  "daydream-diyarbakr",
  "daydream-durham",
  "daydream-folsom",
  "daydream-gahanga",
  "daydream-giza",
  "daydream-hamilton",
  "daydream-hanoi",
  "daydream-heist-op-den-berg",
  "daydream-helsinki",
  "daydream-hyderabad",
  "daydream-inland-empire",
  "daydream-islamabad",
  "daydream-istanbul",
  "daydream-jakarta",
  "daydream-jhansi",
  "daydream-karachi",
  "daydream-kathmandu",
  "daydream-kerala",
  "daydream-khagaria",
  "daydream-khobar",
  "daydream-kigali",
  "daydream-kl",
  "daydream-lagos",
  "daydream-lahore",
  "daydream-leosia",
  "daydream-lima",
  "daydream-london",
  "daydream-manchester",
  "daydream-miami",
  "daydream-missouri",
  "daydream-monterey",
  "daydream-monterrey",
  "daydream-mumbai",
  "daydream-muzaffarpur",
  "daydream-nanjing",
  "daydream-nj",
  "daydream-northfield",
  "daydream-novi",
  "daydream-nyc",
  "daydream-nyregyhza",
  "daydream-omaha",
  "daydream-oshkosh",
  "daydream-ottawa",
  "daydream-padova",
  "daydream-penang",
  "daydream-philippines",
  "daydream-qena",
  "daydream-redsea",
  "daydream-rio-grande-valley",
  "daydream-so-paulo",
  "daydream-saugus",
  "daydream-seattle",
  "daydream-shelburne",
  "daydream-silicon-valley",
  "daydream-south-wales",
  "daydream-sri-lanka",
  "daydream-srinagar",
  "daydream-st-augustine",
  "daydream-stem-qena",
  "daydream-sydney",
  "daydream-taiwan",
  "daydream-tanta",
  "daydream-timisoara",
  "daydream-toronto",
  "daydream-valencia",
  "daydream-vancouver",
  "daydream-visakhapatnam",
  "daydream-warsaw",
  "daydream-yaound",
  "a-really-cool-event"
]

# Create all events from the list
event_names.each do |event_name|
  Event.find_or_create_by!(name: event_name)
end
puts "Created #{event_names.length} events from hardcoded list"

# Fetch Airtable events and create a hash for lookup
puts "Fetching events from Airtable to populate owner emails..."
airtable_events = AirtableService.fetch_events_from_airtable
airtable_lookup = {}

count = 0
airtable_events.each do |event_data|
  puts "  Airtable: '#{event_data[:name]}' -> slug: '#{event_data[:slug]}' -> email: #{event_data[:owner_email].inspect}"
  
  next unless event_data[:slug].present? && event_data[:owner_email].present?
  
  # Extract email from array
  email = event_data[:owner_email].first
  
  if email.present?
    airtable_lookup[event_data[:slug]] = email
    count += 1
    puts "    -> Added to lookup: '#{event_data[:slug]}' = '#{email}'"
  end
end

puts "Processed #{airtable_events.length} events, added #{count} to lookup"

if airtable_lookup.any?
  puts "Found #{airtable_lookup.length} events in Airtable with valid contact info"
  
  # Update existing events with owner email from Airtable
  updated_count = 0
  Event.all.each do |event|
    if airtable_lookup.key?(event.name)
      if airtable_lookup[event.name].present?
        event.update!(owner_email: airtable_lookup[event.name])
        puts "  ✓ Updated #{event.name} with owner email: #{event.owner_email}"
        updated_count += 1
      else
        puts "  ✗ #{event.name} - empty email"
      end
    else
      puts "  ✗ #{event.name} - not found in Airtable"
    end
  end
  
  puts "Updated #{updated_count} events with owner email information"
else
  puts "No events found in Airtable or API key not configured"
end

puts "Finished seeding events!"
