#!/usr/bin/env ruby

# Load everything
$LOAD_PATH << File.expand_path(File.dirname(__FILE__), "lib")
require 'nb-email-processor'

# Connect to nationbuilder in various ways
require 'nationbuilder'
nb = NationBuilder::Client.new(JiffyBag['NATIONBUILDER_NATION'], JiffyBag['NATIONBUILDER_API_KEY'])
website = NationbuilderWebsite.new

# Process all email followups
followups = website.followups
# Print list
puts "Processing #{followups.count} followups"
# Process each one
followups.each do |id|
  begin
    puts "processing person #{id}"
    
    emails = website.emails(id)
    
    # Assign to the first email only for people who mail multiple contacts
    assign(nb, emails.first, id)

    emails.each do |email_body|
      # Tag appropriately
      apply_tags(nb, email_body, id)    
      
      # Set address
      set_address(nb, email_body, id)
      
      # Make geolocation happen
      website.geolocate(id)        
    end
  rescue => ex
    puts ex.message
  end
end