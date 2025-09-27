require 'net/http'
require 'json'

class AirtableService
  BASE_ID = "appmCFCuFmxkvO1zc"
  PROFILE_TABLE_ID = "tblwoiggOeX0s6nyG"
  CONFIRMED_EVENTS_BASE_ID = "appRHzPloxM3u4hUA"
  CONFIRMED_EVENTS_TABLE_ID = "tbl4a18NRx3I4qGPu"
  PROJECTS_BASE_ID = "appRHzPloxM3u4hUA"
  PROJECTS_TABLE_ID = "tblYNkpmgpAdZBV2I"
  
  def self.find_profile_by_email(email)
    return nil unless ENV["AIRTABLE_API_KEY"].present?
    
    Rails.cache.fetch("airtable_profile:#{email.downcase}", expires_in: 1.hour) do
      fetch_profile_from_airtable(email)
    end
  end
  
  def self.fetch_events_from_airtable
    return [] unless ENV["AIRTABLE_API_KEY"].present?
    
    Rails.cache.fetch("airtable_events", expires_in: 1.hour) do
      fetch_all_events
    end
  end
  
  def self.fetch_confirmed_events_from_airtable
    return [] unless ENV["AIRTABLE_API_KEY"].present?
    
    Rails.cache.fetch("airtable_confirmed_events", expires_in: 1.hour) do
      fetch_all_confirmed_events
    end
  end

  def self.fetch_all_projects_from_airtable
    return [] unless ENV["AIRTABLE_API_KEY"].present?
    
    fetch_all_projects_from_api
  end
  
  def self.fetch_all_events
    all_records = []
    offset = nil
    
    loop do
      url = "https://api.airtable.com/v0/#{BASE_ID}/Events"
      uri = URI(url)
      
      # Add offset parameter if we have one
      if offset
        uri.query = URI.encode_www_form({ offset: offset })
      end
      
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        request = Net::HTTP::Get.new(uri)
        request["Authorization"] = "Bearer #{ENV['AIRTABLE_API_KEY']}"
        http.request(request)
      end
      
      if response.code == "200"
        data = JSON.parse(response.body)
        records = data["records"]
        
        # Add records to our collection
        page_records = records.map do |record|
          fields = record["fields"]
          {
            name: fields["name"],
            slug: fields["slug"],
            owner_email: fields["owner_email"]
          }
        end
        
        all_records.concat(page_records)
        
        # Check if there are more pages
        offset = data["offset"]
        break unless offset
      else
        Rails.logger.error "Airtable Events API error: #{response.code} - #{response.body}"
        break
      end
    end
    
    all_records
  rescue => e
    Rails.logger.error "Airtable events fetch error: #{e.message}"
    []
  end
  
  def self.fetch_all_confirmed_events
    all_records = []
    offset = nil
    
    loop do
      url = "https://api.airtable.com/v0/#{CONFIRMED_EVENTS_BASE_ID}/#{CONFIRMED_EVENTS_TABLE_ID}"
      uri = URI(url)
      
      # Add offset parameter if we have one
      if offset
        uri.query = URI.encode_www_form({ offset: offset })
      end
      
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        request = Net::HTTP::Get.new(uri)
        request["Authorization"] = "Bearer #{ENV['AIRTABLE_API_KEY']}"
        http.request(request)
      end
      
      if response.code == "200"
        data = JSON.parse(response.body)
        records = data["records"]
        
        # Add records to our collection
        page_records = records.map do |record|
          fields = record["fields"]
          {
            airtable_id: record["id"],
            email: fields["email"],
            event_name: fields["event_name"]
          }
        end
        
        all_records.concat(page_records)
        
        # Check if there are more pages
        offset = data["offset"]
        break unless offset
      else
        Rails.logger.error "Airtable Confirmed Events API error: #{response.code} - #{response.body}"
        break
      end
    end
    
    all_records
  rescue => e
    Rails.logger.error "Airtable confirmed events fetch error: #{e.message}"
    []
  end
  
  private
  
  def self.fetch_profile_from_airtable(email)
    url = "https://api.airtable.com/v0/#{BASE_ID}/#{PROFILE_TABLE_ID}"
    filter_formula = "LOWER({email}) = '#{email.downcase}'"
    
    uri = URI(url)
    uri.query = URI.encode_www_form({
      filterByFormula: filter_formula,
      maxRecords: 1
    })
    
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "Bearer #{ENV['AIRTABLE_API_KEY']}"
      http.request(request)
    end
    
    if response.code == "200"
      data = JSON.parse(response.body)
      records = data["records"]
      return nil if records.empty?
      
      record = records.first
      fields = record["fields"]
      
      {
        first_name: fields["first_name"],
        last_name: fields["last_name"],
        dob: fields["dob"] ? Date.parse(fields["dob"]) : nil,
        address_line_1: fields["street_1"],
        address_line_2: fields["street_2"],
        address_city: fields["city"],
        address_state: fields["state"],
        address_zip_code: fields["zip_code"],
        address_country: fields["country"]
      }
    else
      Rails.logger.error "Airtable API error: #{response.code} - #{response.body}"
      nil
    end
  rescue => e
    Rails.logger.error "Airtable fetch error: #{e.message}"
    nil
  end

  def self.sync_projects_batch(projects)
    return [] unless ENV["AIRTABLE_API_KEY"].present?
    return [] if projects.empty?

    records = projects.map do |project|
      record_data = project_to_airtable_fields(project)
      
      if project.airtable_record_id.present?
        {
          id: project.airtable_record_id,
          fields: record_data
        }
      else
        {
          fields: record_data
        }
      end
    end

    upsert_airtable_records(records)
  rescue => e
    Rails.logger.error "Airtable projects sync error: #{e.message}"
    []
  end

  private

  def self.project_to_airtable_fields(project)
    fields = {
      project_id: project.id,
      title: project.title,
      readme: project.description,
      code_url: project.repo_url,
      gameplay_url: project.itchio_url
    }

    if project.user
      fields[:email] = project.user.email
    end

    if project.attending_event_id && project.attending_event&.confirmed_event_airtable_id
      fields[:event] = [project.attending_event.confirmed_event_airtable_id]
    end

    fields
  end

  def self.create_airtable_records(records)
    url = "https://api.airtable.com/v0/#{PROJECTS_BASE_ID}/#{PROJECTS_TABLE_ID}"
    uri = URI(url)

    payload = {
      records: records,
      typecast: true
    }

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Post.new(uri)
      request["Authorization"] = "Bearer #{ENV['AIRTABLE_API_KEY']}"
      request["Content-Type"] = "application/json"
      request.body = payload.to_json
      http.request(request)
    end

    if response.code == "200"
      data = JSON.parse(response.body)
      data["records"] || []
    else
      Rails.logger.error "Airtable create error: #{response.code} - #{response.body}"
      []
    end
  end

  def self.update_airtable_records(records)
    url = "https://api.airtable.com/v0/#{PROJECTS_BASE_ID}/#{PROJECTS_TABLE_ID}"
    uri = URI(url)

    payload = {
      records: records,
      typecast: true
    }

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Patch.new(uri)
      request["Authorization"] = "Bearer #{ENV['AIRTABLE_API_KEY']}"
      request["Content-Type"] = "application/json"
      request.body = payload.to_json
      http.request(request)
    end

    if response.code == "200"
      data = JSON.parse(response.body)
      data["records"] || []
    else
      Rails.logger.error "Airtable update error: #{response.code} - #{response.body}"
      []
    end
  end

  def self.upsert_airtable_records(records)
    url = "https://api.airtable.com/v0/#{PROJECTS_BASE_ID}/#{PROJECTS_TABLE_ID}"
    uri = URI(url)

    payload = {
      performUpsert: {
        fieldsToMergeOn: ["project_id"]
      },
      records: records,
      typecast: true
    }

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Patch.new(uri)
      request["Authorization"] = "Bearer #{ENV['AIRTABLE_API_KEY']}"
      request["Content-Type"] = "application/json"
      request.body = payload.to_json
      http.request(request)
    end

    if response.code == "200"
      data = JSON.parse(response.body)
      data["records"] || []
    else
      Rails.logger.error "Airtable upsert error: #{response.code} - #{response.body}"
      []
    end
  end

  def self.fetch_all_projects_from_api
    all_records = []
    offset = nil
    
    loop do
      url = "https://api.airtable.com/v0/#{PROJECTS_BASE_ID}/#{PROJECTS_TABLE_ID}"
      uri = URI(url)
      
      # Add offset parameter if we have one
      if offset
        uri.query = URI.encode_www_form({ offset: offset })
      end
      
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        request = Net::HTTP::Get.new(uri)
        request["Authorization"] = "Bearer #{ENV['AIRTABLE_API_KEY']}"
        http.request(request)
      end
      
      if response.code == "200"
        data = JSON.parse(response.body)
        records = data["records"]
        
        # Add records to our collection with full data
        page_records = records.map do |record|
          fields = record["fields"]
          {
            airtable_record_id: record["id"],
            project_id: fields["project_id"],
            title: fields["title"],
            readme: fields["readme"],
            code_url: fields["code_url"], 
            gameplay_url: fields["gameplay_url"],
            email: fields["email"],
            additional_teammate_1: fields["additional_teammate_1"],
            additional_teammate_2: fields["additional_teammate_2"],
            event: fields["event"],
            event__organizer_email: fields["event__organizer_email"],
            hours: fields["hours"],
            number_of_team_members: fields["number_of_team_members"],
            thumbnail: fields["thumbnail"]
          }
        end
        
        all_records.concat(page_records)
        
        # Check if there are more pages
        offset = data["offset"]
        break unless offset
      else
        Rails.logger.error "Airtable Projects API error: #{response.code} - #{response.body}"
        break
      end
    end
    
    all_records
  rescue => e
    Rails.logger.error "Airtable projects fetch error: #{e.message}"
    []
  end
end
