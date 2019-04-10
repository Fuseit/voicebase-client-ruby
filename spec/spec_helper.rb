$:.unshift File.dirname(__FILE__)+'/../lib'
require 'voicebase'
require 'json'
require 'pp'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
  config.allow_http_connections_when_no_cassette = false
end

RSpec.configure do |config|
  config.color = true
  config.order = 'random'

  config.around(:each, :vcr) do |example|
    test_name = example.metadata[:full_description].split(/\s+/, 2).join("/").downcase.gsub(/[^\w\/]+/, "_")
    VCR.use_cassette(test_name, {}, &example)
  end
end

def get_vb_client
  VoiceBase::Client.new(
    auth_token: 'authToken123',
    host: 'https://apis.voicebase.com',
    debug: false
  )
end
