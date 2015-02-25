require 'jiffybag'

JiffyBag.configure %w{
  NATIONBUILDER_NATION
  NATIONBUILDER_API_KEY
  NATIONBUILDER_USERNAME
  NATIONBUILDER_PASSWORD
}

require 'find_address'
require 'tags'
require 'assign'
require 'nationbuilder_website'