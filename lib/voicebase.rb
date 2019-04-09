# VoiceBase.com Ruby SDK
# Copyright 2015 - Pop Up Archive
# Licensed under Apache 2 license - see LICENSE file
#
#

require 'rubygems'
require 'json'
require 'faraday_middleware'
require 'base64'
require 'uri'
require 'mimemagic'
require 'voicebase/response'
require 'voicebase/client'

module VoiceBase

  module Error
    class NotFound < StandardError
    end
  end

  class FaradayErrHandler < Faraday::Response::Middleware
    def on_complete(env)
      # Ignore any non-error response codes
      return if (status = env[:status]) < 400
      case status
      when 404
        #raise Error::NotFound
        # 404 errors not fatal
      else
        super  # let parent class deal with it
      end
    end
  end
end
