require 'net/http'
require 'json'

class AirtableService
  BASE_ID = "appmCFCuFmxkvO1zc"
  TABLE_ID = "tblwoiggOeX0s6nyG"
  
  def self.find_profile_by_email(email)
    return nil unless ENV["AIRTABLE_API_KEY"].present?
    
    Rails.cache.fetch("airtable_profile:#{email.downcase}", expires_in: 1.hour) do
      fetch_profile_from_airtable(email)
    end
  end
  
  private
  
  def self.fetch_profile_from_airtable(email)
    url = "https://api.airtable.com/v0/#{BASE_ID}/#{TABLE_ID}"
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
end
