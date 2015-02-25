require 'capybara/poltergeist'

class NationbuilderWebsite
  
  include Capybara::DSL
  
  def initialize
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
  end
  
  def followups
    arr = []
    page = 1
    loop do
      visit "https://#{JiffyBag['NATIONBUILDER_NATION']}.nationbuilder.com/admin/streams/followups?page=#{page}"
      page += 1
      page_followups = all(:css, ".followup-content a.full-name").map { |x| x[:href].split('/').last }
      break if page_followups.count == 0
      arr.concat page_followups
    end
    arr
  end
  
  def email_body(id)
    visit "https://#{JiffyBag['NATIONBUILDER_NATION']}.nationbuilder.com/admin/signups/#{id}"
    link = first(:css, ".show-email-body")
    if link
      link.click
      sleep(2)
      first(:css, ".email-body-text")
    else
      nil
    end
  end

  def geolocate(id)
    # Manually hit the save button on addresses to make auto-districting happen
    visit "https://#{JiffyBag['NATIONBUILDER_NATION']}.nationbuilder.com/admin/signups/#{id}/addresses/home"
    click_on "Save address"
    sleep(1)
  end

end