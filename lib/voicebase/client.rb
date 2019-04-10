module VoiceBase
  class Client
    attr_accessor :api_version
    attr_accessor :host
    attr_accessor :debug
    attr_accessor :agent
    attr_accessor :user_agent
    attr_accessor :api_endpoint
    attr_accessor :croak_on_404
    attr_accessor :language

    def version
      return "2.0.0"
    end

    def initialize(args)
      @api_version         = args[:api_version] || '1.1'
      @un                  = args[:username]
      @pw                  = args[:password]
      @auth_id             = args[:id]
      @auth_secret         = args[:secret]
      @oauth_redir_uri     = args[:redir_uri] || 'urn:ietf:wg:oauth:2.0:oob'
      @host                = args[:host] || 'https://apis.voicebase.com'
      @debug               = args[:debug]
      @user_agent          = args[:user_agent] || 'voicebase-client-ruby/'+version()
      @api_endpoint        = args[:api_endpoint] || '/v2-beta'
      @croak_on_404        = args[:croak_on_404] || false
      @language            = args[:language] || 'en'  # US English
      @auth_token          = args[:auth_token]

      # normalize host
      @host.gsub!(/\/$/, '')

      # sanity check
      begin
        uri = URI.parse(@host)
      rescue URI::InvalidURIError => err
        raise "Bad :host value " + err
      end
      if (!uri.host || !uri.port)
        raise "Bad :host value " + @server
      end

      @agent = get_agent

    end

    def get_oauth_token(options = {})
      auth_hash = Base64.strict_encode64( "#{@auth_id}:#{@auth_secret}" ).strip
      opts = {
        :url => @host,
        #:ssl => { :verify => false },
        :headers => {
          'User-Agent' => @user_agent,
          'Accept' => 'application/json',
        }
      }
      conn = Faraday.new(opts) do |faraday|
        faraday.request :url_encoded
        [:mashify, :json].each{|mw| faraday.response(mw) }
        if !@croak_on_404
          faraday.use VoiceBase::FaradayErrHandler
        else
          faraday.response(:raise_error)
        end
        faraday.request :authorization, 'Basic', auth_hash
        faraday.response :logger if @debug
        faraday.adapter  :excon   # IMPORTANT this is last
      end

      resp = conn.get @api_endpoint + '/access/users/admin/tokens'
      token = resp.body["tokens"].first['token']
      #pp token
      return token
    end

    def get_agent(agent_opts = {})
      uri = @host + @api_endpoint
      opts = {
        :url => uri,
        #:ssl => { :verify => false },
        :headers => {
          'User-Agent' => @user_agent,
          'Accept' => 'application/json',
        }
      }.merge(agent_opts)

      @token ||= @auth_token || get_oauth_token

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
        faraday.request :authorization, 'Bearer', @token
        faraday.response :logger if @debug
        faraday.adapter  :excon   # IMPORTANT this is last
      end

      return conn
    end

    def upload(params = {})
      file_path = params[:media]
      raise "'media' required for upload" unless file_path
      raise "'media' #{file_path} is not readable" unless File.exists?(file_path)

      # prep params
      content_type = params[:content_type] || MimeMagic.by_path(file_path).to_s
      params[:media] = Faraday::UploadIO.new(file_path, content_type)

      resp = @agent.post @api_endpoint+'/media', params
      return VoiceBase::Response.new resp
    end

    def transcripts(mediaId, opts = {})
      path = "/media/#{mediaId}/transcripts/latest"
      accept_type = 'application/json'
      if opts[:format] && opts[:format] != 'json'
        accept_type = 'text/' + opts[:format]
      end
      temp_agent = get_agent( {:headers => { 'Accept' => accept_type } } )
      resp = temp_agent.get @api_endpoint+path
      return VoiceBase::Response.new resp
    end

    def get(path, params = {})
      resp = @agent.get @api_endpoint + path, params
      return VoiceBase::Response.new resp
    end

    def post(path, params = {})
      resp = @agent.post @api_endpoint + path, params
      return VoiceBase::Response.new resp
    end

    def method_missing(meth, args, &block)
      if args.size > 0
        get meth, args
      else
        get meth
      end
    end
  end
end
