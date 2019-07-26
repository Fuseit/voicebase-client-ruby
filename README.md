VoiceBase.com Ruby Client SDK
=====================================

http://www.voicebase.com/developers/
https://voicebase.readthedocs.io/en/v3/overview/api_overview.html

Example:

```ruby
require 'voicebase'

# create a client
client = VoiceBase::Client.new(
  :id     => 'apikeystring',
  :secret => 'vb_sekrit_password',
)

resp = client.get '/media'

```

The master branch implements version 3 of the VoiceBase API.

