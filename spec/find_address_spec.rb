require 'spec_helper'

describe "finding addresses" do
  
  it "should extract address without spaces in postcodes" do
    text = <<-EOF.gsub(/^ {6}/, '')
      Dear Mr Smith,
      
      Down with this sort of thing
      
      Yours sincerely,
      Bob Fish
      6 Example Lane
      Test Area
      Horsham
      W. Sussex
      XX123XX
    EOF
    
    expect(find_address text).to eq <<-EOF.gsub(/^ {6}/, '').strip
      6 Example Lane
      Test Area
      Horsham
      W. Sussex
      XX123XX
    EOF
  end
  
  it "should extract address with trailing whitespace" do
    text = <<-EOF.gsub(/^ {6}/, '')
      Dear Mr Smith,
      
      Down with this sort of thing
      
      Yours sincerely,
      Bob Fish 
      6 Example Lane 
      Test Area 
      Horsham 
      W. Sussex 
      XX123XX 
      Hello 
    EOF
    
    expect(find_address text).to eq <<-EOF.gsub(/^ {6}/, '').strip
      6 Example Lane 
      Test Area 
      Horsham 
      W. Sussex 
      XX123XX 
    EOF
  end

  it "should extract address with lowercase postcodes" do
    text = <<-EOF.gsub(/^ {6}/, '')
      Dear Mr Smith,
      
      Down with this sort of thing
      
      Yours sincerely,
      Bob Fish
      6 Example Lane
      Test Area
      Horsham
      W. Sussex
      xx123xx
    EOF
    
    expect(find_address text).to eq <<-EOF.gsub(/^ {6}/, '').strip
      6 Example Lane
      Test Area
      Horsham
      W. Sussex
      xx123xx
    EOF
  end
    it "should extract address with spaces in postcodes" do
    text = <<-EOF.gsub(/^ {6}/, '')
      Dear Mr Smith,
      
      Down with this sort of thing
      
      Yours sincerely,
      Bob Fish
      6 Example Lane
      Test Area
      Horsham
      W. Sussex
      XX12 3XX
    EOF
    
    expect(find_address text).to eq <<-EOF.gsub(/^ {6}/, '').strip
      6 Example Lane
      Test Area
      Horsham
      W. Sussex
      XX12 3XX
    EOF
  end
  
  it "should extract address with a gap before the address" do
    text = <<-EOF.gsub(/^ {6}/, '')
      Dear Mr Smith,
      
      Down with this sort of thing
      
      Yours sincerely,
      
      
      Bob Fish
      6 Example Lane
      Test Area
      Horsham
      W. Sussex
      XX12 3XX
    EOF
    
    expect(find_address text).to eq <<-EOF.gsub(/^ {6}/, '').strip
      6 Example Lane
      Test Area
      Horsham
      W. Sussex
      XX12 3XX
    EOF
  end

  it "should extract address with a different signoff" do
    text = <<-EOF.gsub(/^ {6}/, '')
      Dear Mr Smith,
      
      Down with this sort of thing
      
      Best wishes,
      
      
      Bob Fish
      6 Example Lane
      Test Area
      Horsham
      W. Sussex
      XX12 3XX
    EOF
    
    expect(find_address text).to eq <<-EOF.gsub(/^ {6}/, '').strip
      6 Example Lane
      Test Area
      Horsham
      W. Sussex
      XX12 3XX
    EOF
  end

end