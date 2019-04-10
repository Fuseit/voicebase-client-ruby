module VoiceBase
  class Response
    attr_accessor :http_resp

    def initialize(http_resp)
      @http_resp = http_resp
      @is_ok = false
      if http_resp.status.to_s =~ /^2\d\d/
        @is_ok = true
      end
    end

    def status()
      return @http_resp.status
    end

    def is_success()
      return @is_ok
    end

    def body
      @http_resp.body
    end

    def method_missing(meth, *args, &block)
      if @http_resp.body.respond_to? meth
        @http_resp.body.send(meth, *args, &block)
      else
        super
      end
    end

    def respond_to?(meth)
      if @http_resp.body.respond_to? meth
        true
      else
        super
      end
    end
  end
end
