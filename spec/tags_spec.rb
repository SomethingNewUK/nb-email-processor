require 'spec_helper'

describe "tagging subjects" do

  it "should detect string in email and tag" do
    
    text = "blah blah HSBC has been helping the super-rich dodge their tax something something"
    
    nb = double("Nationbuilder API")
    expect(nb).to receive(:call).with(:people, :tag_person, id: 10, tagging: { 
      tag: ['hsbc-tax-dodging-38-degrees'] 
    })
    
    apply_tags(nb, text, 10)
    
  end
  
end