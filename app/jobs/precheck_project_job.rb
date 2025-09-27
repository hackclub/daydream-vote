require 'httparty'
require 'nokogiri'

class PrecheckProjectJob < ApplicationJob
  queue_as :default

  def perform(precheck)
    project = precheck.project
    
    if project.itchio_url.blank?
      precheck.update!(
        status: :failed,
        message: "No itch.io URL provided"
      )
      return
    end

    if check_itchio_playable(project.itchio_url)
      precheck.update!(
        status: :passed,
        message: "itch.io game has a play button and appears to be playable!"
      )
    else
      precheck.update!(
        status: :failed,
        message: "itch.io game does not appear to have a play button or may not be playable in browser"
      )
    end
  rescue => e
    precheck.update!(
      status: :failed,
      message: "Precheck failed: #{e.message}"
    )
  end

  private

  def check_itchio_playable(url)
    # Fetch the page content
    response = HTTParty.get(url, timeout: 10, headers: {
      'User-Agent' => 'Mozilla/5.0 (compatible; DaydreamVoteBot/1.0)'
    })
    
    return false unless response.code == 200
    
    # Parse HTML content
    doc = Nokogiri::HTML(response.body)
    
    # Look for itch.io's game frame - the most reliable indicator
    doc.css('.game_frame').any?
  end
end
