class EbayRequest::Base
  def initialize(options = {})
    @options = options
    @config = EbayRequest.config(options[:env])
  end

  attr_reader :options, :config

  def response(callname, payload)
    config.validate!
    request(URI.parse(with_sandbox(endpoint)), callname, payload)
  end

  def response!(callname, payload)
    response(callname, payload).data!
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

  def with_sandbox(value)
    value % { sandbox: config.sandbox? ? ".sandbox" : "" }
  end

  def specific_error_classes
    {}
  end

  private

  def error_class(code)
    error = specific_error_classes.find { |_, v| v & [code] }
    return error.first if error
  end

  def request(url, callname, request)
    h = headers(callname)
    b = payload(callname, request)

    post = Net::HTTP::Post.new(url.path, h)
    post.body = b

    response, time = make_request(url, post)
    EbayRequest.log(url, h, b, response)
    EbayRequest.log_time(callname, time)

    process(parse(response), callname)
  end

  def make_request(url, post)
    start_time = Time.now
    http = prepare(url)
    response = http.start { |r| r.request(post) }.body
    [response, Time.now - start_time]
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
