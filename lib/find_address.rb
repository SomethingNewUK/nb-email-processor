require 'httparty'
require 'active_support/all'

def set_address(nb, text, id)
  existing_address = nb.call(:people, :show, id: id.to_i)['person']['home_address']
  if existing_address.nil? || existing_address.all?{|x| x[1]==nil || x[1]==""}
    addr = find_address(text)
    if addr
      address = parse_address(addr)
      if address
        puts "Storing address for user #{id}: #{address.to_json.inspect}"
        nb.call(:people, :update, id: id.to_i, person: {home_address: address})
      else
        puts "Failed to parse address for user #{id}: #{addr}"
      end
    else
      puts "Couldn't find address for user #{id}"
    end
  else
    puts "Skipping address for user #{id}"
  end
end


def find_address(text)
  # Terrible multi-line regexp
  re = /[ys],?\s*\n+.*?\n(.*[A-Za-z]{2}[0-9]{1,2} ?[0-9]{1}[A-Za-z]{2})\s*\n/m
  match = text.match re
  match ? match[1] : nil
end

def parse_address(addr)
  postcode = addr.split("\n").last
  begin
    parsed_address = JSON.parse(HTTParty.post('https://sorting-office.openaddressesuk.org/address', 
      :query => { :address => addr }).body)
    paon = [parsed_address['paon'].try(:[], 'name'), parsed_address['street'].try(:[], 'name')].join(' ')
    address = {
      address1: parsed_address['saon'].try(:[], 'name') || paon ,
      address2: parsed_address['saon'].nil? ? parsed_address['locality'].try(:[], 'name') : paon,
      address3: parsed_address['saon'].nil? ? nil : parsed_address['locality'].try(:[], 'name'),
      city: parsed_address['town'].try(:[], 'name'),
      zip: parsed_address['postcode'].try(:[], 'name') || postcode #fallback
    }
  rescue JSON::ParserError    
    puts "JSON parse failed when parsing #{addr}"
    # We know there's a postcode, so just use that
    address = {
      zip: postcode
    }
  end
end