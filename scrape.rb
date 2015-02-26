#!/usr/bin/env ruby

# Load everything
$LOAD_PATH << File.expand_path(File.dirname(__FILE__), "lib")
require 'nb-email-processor'

# Connect to nationbuilder in various ways
require 'nationbuilder'
nb = NationBuilder::Client.new(JiffyBag['NATIONBUILDER_NATION'], JiffyBag['NATIONBUILDER_API_KEY'])
website = NationbuilderWebsite.new

# Process all email followups
website.followups.each do |id|
  puts "processing person #{id}"
  
  email_body = website.email_body(id)
  
  if email_body
    email_body = email_body.native.command(:all_text)

    # Assign
    assign(nb, email_body, id)

    # Tag appropriately
    apply_tags(nb, email_body, id)    
    
    # Set address
    set_address(nb, email_body, id)
    
    # Make geolocation happen
    website.geolocate(id)
  end
end