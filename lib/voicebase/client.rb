module VoiceBase
  class Client
    attr_accessor :api_version
    attr_accessor :host
    attr_accessor :debug
    attr_accessor :user_agent
    attr_accessor :api_endpoint
    attr_accessor :croak_on_404
    attr_accessor :language

    TRANSCRIPT_ACCEPT_TYPE = { 'srt' => 'text/srt', 'text' => 'text/plain', 'webvtt' => 'text/vtt' }.freeze

    def version
      return "3.0.0"
    end

    def initialize(args)
      @api_version         = args[:api_version] || '3.0'
      @host                = args[:host] || 'https://apis.voicebase.com'
      @debug               = args[:debug]
      @user_agent          = args[:user_agent] || 'voicebase-client-ruby/'+version()
      @api_endpoint        = args[:api_endpoint] || '/v3'
      @croak_on_404        = args[:croak_on_404] || false
      @language            = args[:language] || 'en'  # US English
      @auth_token          = args[:auth_token]
    end

    def file_upload(params = {})
      file_path = params[:media]
      raise "'media' required for upload" unless file_path
      raise "'media' #{file_path} is not readable" unless File.exists?(file_path)

      # prep params
      content_type = params[:content_type] || MimeMagic.by_path(file_path).to_s
      params[:media] = Faraday::UploadIO.new(file_path, content_type)

      response = agent.post @api_endpoint + '/media', params
      return VoiceBase::Response.new response
    end

    def upload body, params = {}
      response = agent.post do |request|
        request.url @api_endpoint + '/media'
        request.headers['Content-Type'] = params[:content_type] || 'multipart/form-data'
        request.body = body
      end

      return VoiceBase::Response.new response
    end

    def get_mediaId(mediaId)
      get "/media/#{mediaId}"
    end

    def get_media
      get '/media'
    end

    def transcript(mediaId, opts = {})
      path = "/media/#{mediaId}/transcript/#{opts[:format]}"
      accept_type = TRANSCRIPT_ACCEPT_TYPE[opts[:format]] || raise('UnknownTranscriptFormat')

      temp_agent = agent( {:headers => { 'Accept' => accept_type } } )
      resp = temp_agent.get @api_endpoint+path
      return VoiceBase::Response.new resp
    end

    private

    def get(path, params = {})
      resp = agent.get @api_endpoint + path, params
      return VoiceBase::Response.new resp
    end

    def post(path, params = {})
      resp = agent.post @api_endpoint + path, params
      return VoiceBase::Response.new resp
    end

    def agent(agent_opts = {})
      uri = @host + @api_endpoint
      opts = {
        :url => uri,
        #:ssl => { :verify => false },
        :headers => {
          'User-Agent' => @user_agent,
          'Accept' => 'application/json',
        }
      }.merge(agent_opts)

      conn = Faraday.new(opts) do |faraday|
        faraday.request :multipart
        faraday.request :url_encoded
        if opts[:headers]['Accept'] == 'application/json'
          [:mashify, :json].each{|mw| faraday.response(mw) }
        end
        if !@croak_on_404
          faraday.use VoiceBase::FaradayErrHandler
        else
          faraday.response(:raise_error)
        end
        faraday.request :authorization, 'Bearer', @auth_token
        faraday.response :logger if @debug
        faraday.adapter  :excon   # IMPORTANT this is last
      end

      return conn
    end
  end
end
