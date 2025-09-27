require 'httparty'
require 'nokogiri'

class ItchioChecker
  def self.playable?(url)
    new.playable?(url)
  end

  def playable?(url)
    return false if url.blank?
    
    # Fetch the page content
    response = HTTParty.get(url, timeout: 10, headers: {
      'User-Agent' => 'Mozilla/5.0 (compatible; DaydreamVoteBot/1.0)'
    })
    
    return false unless response.code == 200
    
    # Parse HTML content
    doc = Nokogiri::HTML(response.body)
    
    # Look for itch.io's game frame - the most reliable indicator
    doc.css('.game_frame').any?
  rescue => e
    Rails.logger.error "ItchioChecker error for #{url}: #{e.message}"
    false
  end
end
