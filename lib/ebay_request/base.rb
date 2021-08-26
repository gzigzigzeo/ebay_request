# frozen_string_literal: true

class EbayRequest::Base
  def initialize(options = {})
    @options = options
  end

  attr_reader :options

  def config
    @config ||= EbayRequest.config(options[:env])
  end

  def siteid
    @siteid ||=
      options[:siteid] ||
      EbayRequest::Config.site_id_from_globalid(options[:globalid]) ||
      0
  end

  def globalid
    @globalid ||=
      options[:globalid] ||
      EbayRequest::Config.globalid_from_site_id(options[:siteid]) ||
      "EBAY-US"
  end

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
    {
      "Accept" => "text/xml",
      "Accept-Charset" => "utf-8",
      "Content-Type" => "text/xml; charset=utf-8",
      **options.fetch(:headers, {}),
    }
  end

  def payload(_callname, _request)
    raise NotImplementedError, "Implement #{self.class.name}#payload"
  end

  def parse(response)
    MultiXml.parse(response)
  end

  def process(response, callname)
    data = response["#{callname}Response"]

    raise EbayRequest::Error::BlankResponse, "#{callname} response is blank" if data.nil?

    EbayRequest::Response.new(
      callname, data, errors_for(data), self.class::FATAL_ERRORS
    )
  end

  def with_sandbox(value)
    # rubocop:disable Style/FormatString
    value % { sandbox: config.sandbox? ? ".sandbox" : "" }
    # rubocop:enable Style/FormatString
  end

  # rubocop:disable Metrics/MethodLength
  def request(url, callname, request)
    h = headers(callname)
    b = payload(callname, request)

    post = Net::HTTP::Post.new(url.path, h)
    post.body = b

    response, time = make_request(url, post)

    response_object = process(parse(response), callname)
  ensure
    EbayRequest.log(
      url: url.to_s,
      callname: callname,
      headers: h,
      request_payload: b,
      response_payload: response,
      time: time,
      warnings: response_object&.warnings,
      errors: response_object&.errors,
      success: response_object&.success?,
      version: response_object&.version
    )
  end
  # rubocop:enable Metrics/MethodLength

  def make_request(url, post)
    start_time = Time.now
    http = prepare(url)
    response = http.start { |r| r.request(post) }.body
    [response, Time.now - start_time]
  end

  def prepare(url)
    Net::HTTP.new(url.host, url.port).tap do |http|
      http.read_timeout = config.timeout
      http.use_ssl = url.port == 443
    end
  end

  def errors_for(_response)
    raise NotImplementedError, "Implement #{self.class.name}#errors_for"
  end
end
