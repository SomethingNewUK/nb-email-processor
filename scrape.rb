#!/usr/bin/env ruby
require 'bundler'
Bundler.require

require 'capybara/poltergeist'
require 'httparty'

JiffyBag.configure %w{
  NATIONBUILDER_NATION
  NATIONBUILDER_API_KEY
  NATIONBUILDER_USERNAME
  NATIONBUILDER_PASSWORD
}

require 'nationbuilder'

nb = NationBuilder::Client.new(JiffyBag['NATIONBUILDER_NATION'], JiffyBag['NATIONBUILDER_API_KEY'])

taggings = YAML.load_file('tags.yml')

include Capybara

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, 
    :phantomjs_options => ['--load-images=no', '--ignore-ssl-errors=yes', '--ssl-protocol=TLSv1'], 
    :debug => false )
end
Capybara.default_driver = :poltergeist
Capybara.javascript_driver = :poltergeist

@session = Capybara::Session.new(:poltergeist)

visit "https://somethingnew.nationbuilder.com/forms/user_sessions/new"

fill_in 'user_session_email', with: JiffyBag["NATIONBUILDER_USERNAME"]
fill_in 'user_session_password', with: JiffyBag["NATIONBUILDER_PASSWORD"]
click_button 'Sign in with email'

# Wait for sign in
sleep(10)

followups = []
page = 1
loop do
  visit "https://#{JiffyBag['NATIONBUILDER_NATION']}.nationbuilder.com/admin/streams/followups?page=#{page}"
  page += 1
  page_followups = all(:css, ".followup-content a.full-name").map { |x| x[:href] }
  break if page_followups.count == 0
  followups.concat page_followups
end

re = /y,\n.*?\n(.*[0-9]{2}[A-Z]{2})\n/m

followups.each do |href|
  id = href.split('/').last
  visit "https://#{JiffyBag['NATIONBUILDER_NATION']}.nationbuilder.com#{href}"
  link = first(:css, ".show-email-body")
  if link
    link.click
    sleep(2)
    body = first(:css, ".email-body-text")
    
    tags = []
    taggings.each_pair do |key, value|
      if body.text.match value
        tags << key
      end
    end
    unless tags.empty?
      puts "Tagging user #{id} with #{tags.inspect}"
      nb.call(:people, :tag_person, id: id.to_i, tagging: { tag: tags })
    end
    if nb.call(:people, :show, id: id.to_i)['person']['home_address'].nil?
      match = body.html.match re
      if match
        parsed_address = JSON.parse(HTTParty.post('https://sorting-office.openaddressesuk.org/address', 
          :query => { :address => match[1] }).body)
        paon = [parsed_address['paon'], parsed_address['street']].join(' ')
        address = {
          address1: parsed_address['saon'] || paon ,
          address2: parsed_address['saon'].nil? ? parsed_address['locality'] : paon,
          address3: parsed_address['saon'].nil? ? nil : parsed_address['locality'],
          city: parsed_address['town'],
          zip: parsed_address['postcode']
        }
        puts "Storing address for user #{id}: #{address.to_json.inspect}"
        nb.call(:people, :update, id: id.to_i, person: {home_address: address})
      end
    end
    # Manually hit the save button on addresses to make auto-districting happen
    visit "https://#{JiffyBag['NATIONBUILDER_NATION']}.nationbuilder.com/admin/signups/#{id}/addresses/home"
    click_on "Save address"
    sleep(1)
  end
end