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

# Fetch Confirmed Events from Airtable and match by email
puts "Fetching confirmed events from Airtable to populate confirmed_event_airtable_id..."
confirmed_events = AirtableService.fetch_confirmed_events_from_airtable
confirmed_events_lookup = {}

confirmed_events.each do |confirmed_event_data|
  puts "  Confirmed Event: airtable_id: '#{confirmed_event_data[:airtable_id]}' -> email: #{confirmed_event_data[:email].inspect} -> event_name: #{confirmed_event_data[:event_name].inspect}"
  
  next unless confirmed_event_data[:email].present? && confirmed_event_data[:airtable_id].present?
  
  # Create lookup by email
  confirmed_events_lookup[confirmed_event_data[:email].downcase] = {
    airtable_id: confirmed_event_data[:airtable_id],
    event_name: confirmed_event_data[:event_name]
  }
end

puts "Processed #{confirmed_events.length} confirmed events, added #{confirmed_events_lookup.length} to lookup"

if confirmed_events_lookup.any?
  puts "Found #{confirmed_events_lookup.length} confirmed events in Airtable with valid data"
  
  # Update existing events with confirmed_event_airtable_id and humanized_name by matching owner_email
  confirmed_updated_count = 0
  Event.where.not(owner_email: nil).each do |event|
    event_email = event.owner_email.downcase
    if confirmed_events_lookup.key?(event_email)
      confirmed_data = confirmed_events_lookup[event_email]
      update_attrs = { confirmed_event_airtable_id: confirmed_data[:airtable_id] }
      
      # Set humanized_name if available
      if confirmed_data[:event_name].present?
        update_attrs[:humanized_name] = confirmed_data[:event_name]
      end
      
      event.update!(update_attrs)
      puts "  ✓ Updated #{event.name} with confirmed_event_airtable_id: #{event.confirmed_event_airtable_id} and humanized_name: #{event.humanized_name.inspect}"
      confirmed_updated_count += 1
    else
      puts "  ✗ #{event.name} (#{event.owner_email}) - no matching confirmed event"
    end
  end
  
  puts "Updated #{confirmed_updated_count} events with confirmed_event_airtable_id information"
else
  puts "No confirmed events found in Airtable or API key not configured"
end

puts "Finished seeding events!"

# Load all projects from Airtable
puts "\nFetching projects from Airtable..."
airtable_projects = AirtableService.fetch_all_projects_from_airtable

if airtable_projects.empty?
  puts "No projects found in Airtable or API key not configured"
else
  puts "Found #{airtable_projects.length} projects in Airtable"
  
  # Create a lookup for events by organizer email
  event_by_organizer_email = {}
  Event.where.not(owner_email: nil).each do |event|
    event_by_organizer_email[event.owner_email.downcase] = event
  end
  
  created_projects_count = 0
  updated_projects_count = 0
  created_users_count = 0
  
  airtable_projects.each_with_index do |project_data, index|
    puts "\nProcessing project #{index + 1}/#{airtable_projects.length}: #{project_data[:title]}"
    
    # Skip if missing required data
    unless project_data[:title].present? && project_data[:email].present?
      puts "  ✗ Skipping - missing title or email"
      next
    end
    
    # Find or create the primary user
    primary_user = User.find_or_create_by!(email: project_data[:email].downcase) do |user|
      puts "  ✓ Creating user: #{project_data[:email]}"
      created_users_count += 1
    end
    
    # Find the associated event by organizer email
    associated_event = nil
    if project_data[:event__organizer_email].present?
      organizer_emails = project_data[:event__organizer_email]
      organizer_emails.each do |organizer_email|
        if event_by_organizer_email.key?(organizer_email.downcase)
          associated_event = event_by_organizer_email[organizer_email.downcase]
          puts "  ✓ Found event: #{associated_event.name} (organizer: #{organizer_email})"
          break
        end
      end
    end
    
    unless associated_event
      puts "  ✗ No matching event found for organizer emails: #{project_data[:event__organizer_email]}"
      next
    end
    
    # Find or create the project
    existing_project = nil
    
    # First try to find by airtable_record_id if we have one
    if project_data[:airtable_record_id].present?
      existing_project = Project.find_by(airtable_record_id: project_data[:airtable_record_id])
    end
    
    # If not found, try to find by project owner, event, and title
    unless existing_project
      existing_project = Project.joins(:creator_positions, :users)
                               .where(creator_positions: { role: 'owner' })
                               .where(users: { id: primary_user.id })
                               .where(attending_event: associated_event)
                               .where(title: project_data[:title])
                               .first
    end
    
    project_attributes = {
      title: project_data[:title],
      description: project_data[:readme] || "",
      repo_url: project_data[:code_url] || "",
      itchio_url: project_data[:gameplay_url] || "",
      attending_event: associated_event,
      aasm_state: 'submitted',
      submitted_at: Time.current,
      airtable_record_id: project_data[:airtable_record_id],
      last_synced_to_airtable_at: Time.current
    }
    
    if existing_project
      existing_project.assign_attributes(project_attributes)
      existing_project.skip_url_validations = true
      existing_project.save!
      puts "  ✓ Updated existing project: #{existing_project.title}"
      updated_projects_count += 1
      current_project = existing_project
    else
      current_project = Project.new(project_attributes)
      current_project.skip_url_validations = true
      current_project.save!
      puts "  ✓ Created new project: #{current_project.title}"
      created_projects_count += 1
      
      # Create owner creator position
      CreatorPosition.create!(
        project: current_project,
        user: primary_user,
        role: 'owner'
      )
    end
    

    
    # Handle additional teammates
    [project_data[:additional_teammate_1], project_data[:additional_teammate_2]].compact.each do |teammate_email|
      next unless teammate_email.present?
      
      teammate_user = User.find_or_create_by!(email: teammate_email.downcase) do |user|
        puts "    ✓ Creating teammate user: #{teammate_email}"
        created_users_count += 1
      end
      
      # Create collaborator position if not exists
      unless current_project.creator_positions.joins(:user).where(users: { id: teammate_user.id }).exists?
        CreatorPosition.create!(
          project: current_project,
          user: teammate_user,
          role: 'collaborator'
        )
        puts "    ✓ Added teammate as collaborator: #{teammate_email}"
      else
        puts "    ✓ Teammate already exists: #{teammate_email}"
      end
    end
  end
  
  puts "\n" + "="*50
  puts "AIRTABLE PROJECTS SEEDING COMPLETE"
  puts "="*50
  puts "Created #{created_projects_count} new projects"
  puts "Updated #{updated_projects_count} existing projects"  
  puts "Created #{created_users_count} new users"
  puts "All projects are marked as 'submitted'"
end

puts "\nFinished seeding projects from Airtable!"

# Now sync images in parallel for much better performance
puts "\n🖼️  Syncing project images from Airtable (multithreaded)..."

require 'concurrent-ruby'

# Create lookup hash by airtable_record_id for O(1) lookups
airtable_image_lookup = {}
airtable_projects.each do |project_data|
  if project_data[:airtable_record_id].present? && project_data[:thumbnail].present?
    airtable_image_lookup[project_data[:airtable_record_id]] = project_data[:thumbnail]
  end
end

puts "#{airtable_image_lookup.length} projects have images in Airtable"

# Find projects that need images
projects_needing_images = Project.where.missing(:image_attachment)
                                 .where.not(airtable_record_id: nil)
                                 .where(airtable_record_id: airtable_image_lookup.keys)

puts "#{projects_needing_images.count} projects need images synced"

if projects_needing_images.count > 0
  # Thread-safe counters
  success_count = Concurrent::AtomicFixnum.new(0)
  failure_count = Concurrent::AtomicFixnum.new(0)
  skipped_count = Concurrent::AtomicFixnum.new(0)

  # Create a thread-safe work queue with all projects
  work_queue = Queue.new
  projects_needing_images.each { |project| work_queue << project }
  
  # Thread pool for downloading images  
  thread_pool_size = 32
  puts "Using #{thread_pool_size} worker threads with work queue..."
  puts "Queue size: #{work_queue.size} projects"

  # Create worker threads that continuously pull from the queue
  threads = Array.new(thread_pool_size) do |thread_id|
    Thread.new do
      loop do
        begin
          project = work_queue.pop(true) # non-blocking pop, raises ThreadError when empty
        rescue ThreadError
          # Queue is empty, exit thread
          break
        end

        begin
          thumbnail_data_array = airtable_image_lookup[project.airtable_record_id]
          
          unless thumbnail_data_array.is_a?(Array) && !thumbnail_data_array.empty?
            skipped_count.increment
            next
          end
          
          thumbnail_data = thumbnail_data_array.first
          unless thumbnail_data['url'].present?
            skipped_count.increment
            next
          end
          
          require 'open-uri'
          
          image_url = thumbnail_data['url']
          filename = thumbnail_data['filename'] || 'thumbnail.png'
          content_type = thumbnail_data['type'] || 'image/png'
          file_size = thumbnail_data['size'] || 'unknown'
          
          puts "  📥 [T#{thread_id}] #{filename} for \"#{project.title}\" (#{file_size} bytes)"
          
          # Skip URL validations to prevent validation failures during image attachment
          project.skip_url_validations = true
          
          # Download and attach the image
          project.image.attach(
            io: URI.open(image_url),
            filename: filename,
            content_type: content_type
          )
          
          success_count.increment
          
        rescue => e
          failure_count.increment
          puts "  ❌ [T#{thread_id}] Failed: \"#{project.title}\" - #{e.message}"
        end
      end
    end
  end

  # Wait for all worker threads to complete
  threads.each(&:join)

  puts "\n" + "="*60
  puts "🎉 IMAGE SYNC COMPLETE"
  puts "="*60
  puts "✅ Successfully synced: #{success_count.value} images"
  puts "⚠️  Skipped: #{skipped_count.value} projects"  
  puts "❌ Failed: #{failure_count.value} projects"

  # Verify final count
  total_with_images = Project.joins(:image_attachment).count
  puts "\n📊 Total projects with images: #{total_with_images}"
  puts "📊 Coverage: #{(total_with_images.to_f / Project.count * 100).round(1)}%"
else
  puts "All projects already have images!"
end
