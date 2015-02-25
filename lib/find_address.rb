require 'httparty'

def set_address(nb, text, id)
  existing_address = nb.call(:people, :show, id: id.to_i)['person']['home_address']
  if existing_address.nil? || existing_address.all?{|x| x[1]==nil || x[1]==""}
    addr = find_address(text)
    if addr
      parsed_address = JSON.parse(HTTParty.post('https://sorting-office.openaddressesuk.org/address', 
        :query => { :address => addr }).body)
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
end


def find_address(text)
  # Terrible multi-line regexp
  re = /[ys],\s*\n+.*?\n(.*[A-Za-z]{2}[0-9]{1,2} ?[0-9]{1}[A-Za-z]{2})\s*\n/m
  match = text.match re
  match ? match[1] : nil
end