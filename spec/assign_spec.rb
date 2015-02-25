require 'spec_helper'

describe "assigning point people" do

  it "should detect name in email and reassign" do
    
    text = "Hello Mr Paul Robinson, how are you"
    
    nb = double("Nationbuilder API")
    expect(nb).to receive(:call).with(:people, :update, id: 10, person: { parent_id: 48})
    
    assign(nb, text, 10)
    
  end
  
end