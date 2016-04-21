class EbayRequest::Base
  def initialize(options = {})
    @options = options
    @config = EbayRequest.config(options[:env])
  end

  attr_reader :options, :config

  def response(callname, payload)
    config.validate!
    request(URI.parse(endpoint_with_sandbox), callname, payload)
  end

  protected

  def endpoint
    raise NotImplementedError, "Implement #{self.class.name}#endpoint"
  end

  def ns
    "urn:ebay:apis:eBLBaseComponents"
  end

  def headers(_callname)
    {}
  end

  def payload(_callname, _request)
    {}
  end

  def parse(_response)
    raise NotImplementedError, "Define #parse for API #{self.class.name}"
  end

  def process(_response, _callname)
    raise NotImplementedError, "Define #process for API #{self.class.name}"
  end

  private

  def endpoint_with_sandbox
    endpoint % { sandbox: config.sandbox? ? ".sandbox" : "" }
  end

  def request(url, callname, request)
    h = headers(callname)
    b = payload(callname, request)
    http = prepare(url)

    post = Net::HTTP::Post.new(url.path, h)
    post.body = b

    response = http.start { |r| r.request(post) }.body
    EbayRequest.log(url, h, b, response)
    process(parse(response), callname)
  end

  def prepare(url)
    Net::HTTP.new(url.host, url.port).tap do |http|
      http.read_timeout = config.timeout

      if url.port == 443
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end
  end
end
