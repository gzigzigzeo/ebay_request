class EbayRequest::Base
  def initialize(options)
    @options = options
  end

  attr_reader :options

  protected

  def endpoint
    raise NotImplementedError, "Implement #{class.name}#endpoint"
  end

  def ns
    "urn:ebay:apis:eBLBaseComponents"
  end

  def headers(callname)
    {
      "Content-Type" => "text/xml"
    }
  end

  private

  def endpoint_with_sandbox
    endpoint % ".sandbox" if config.sandbox?
  end

  def request(url, callname, input)
    h = headers(callname)
    b = body(callname, input)

    http = prepare(url)

    post = Net::HTTP::Post.new(url.path, h)
    post.body = b

    response = http.start { |r| r.request(post) }.body

    log(url, h, b, response) if @logger

    MultiXml.parse(response)
  end

  def prepare(url)
    Net::HTTP.new(url.host, url.port).tap do |http|
      http.read_timeout = @timeout

      if url.port == 443
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end
  end
end
