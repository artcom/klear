$:.unshift(File.dirname(__FILE__))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rspec/mocks'
require 'klear'

RSpec.configure do |config|
  config.add_setting(
    :fixtures,
    default: "#{File.dirname(__FILE__)}/fixtures",
    alias_with: :fixtures, 
  )

  config.before :each do
  end

  config.after :each do
  end
end
