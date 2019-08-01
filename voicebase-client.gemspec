Gem::Specification.new do |s|
  s.name        = 'voicebase'
  s.version     = '3.0.0'
  s.date        = '2015-04-21'
  s.rubyforge_project = "nowarning"
  s.summary     = "Ruby client for voicebase.com API"
  s.description = "Ruby client for voicebase.com API"
  s.authors     = ["Peter Karman"]
  s.email       = 'peter@popuparchive.com'
  s.homepage    = 'https://github.com/popuparchive/voicebase-client-ruby'
  s.files       = ["lib/voicebase.rb"]
  s.license     = 'Apache'
  s.add_runtime_dependency "faraday"
  s.add_runtime_dependency "faraday_middleware"
  s.add_runtime_dependency "excon"
  s.add_runtime_dependency "hashie"
  s.add_runtime_dependency "mimemagic"
  s.add_development_dependency "rspec"
  s.add_development_dependency 'rspec_junit_formatter'
  s.add_development_dependency "dotenv"
  s.add_development_dependency "vcr"
  s.add_development_dependency "webmock"
end
