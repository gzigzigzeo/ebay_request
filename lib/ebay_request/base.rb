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

  private

  def endpoint
    raise NotImplementedError, "Implement #{self.class.name}#endpoint"
  end

  def headers(_callname)
    {}
  end

  def payload(_callname, _request)
    {}
  end

  def parse(response)
    MultiXml.parse(response)
  end

  def process(response, callname)
    r = response["#{callname}Response"]

    raise EbayRequest::Error, "No response" if r.nil?

    ack = r["ack"] || r["Ack"]
    success = %w(Success Warning).include? ack

    errors, warnings = split_errors_and_warnings(errors_for(r))

    EbayRequest::Response.new(r, success, errors, warnings, callname)
  end

  def with_sandbox(value)
    value % { sandbox: config.sandbox? ? ".sandbox" : "" }
  end

  def specific_error_classes
    {}
  end

  def split_errors_and_warnings(errs)
    errors = []
    warnings = []

    errs.each do |severity, code, message|
      if severity == "Warning"
        warnings << [code.to_i, message]
      else
        errors << [code.to_i, message, error_class(code.to_i)]
      end
    end

    [errors, warnings]
  end

  def error_class(code)
    error = specific_error_classes.find { |_, v| (v & [code]).any? }
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

  def errors_for(_r)
    raise NotImplementedError, "Implement #{self.class.name}#errors_for"
  end
end
