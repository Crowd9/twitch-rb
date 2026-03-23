require 'rspec'
require 'webmock/rspec'
require 'twitch'

RSpec.configure do |config|
  config.color = true
  config.formatter = 'documentation'
end
