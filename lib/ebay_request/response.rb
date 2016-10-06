class EbayRequest::Response
  attr_reader :data, :errors, :warnings

  def initialize(data, success, errors, warnings, callname)
    @data = data
    @success = success
    @errors = errors
    @warnings = warnings
    @callname = callname
  end

  def success?
    @success
  end

  def data!
    unless success?
      raise EbayRequest::Error.new(error_message, self, error_codes)
    end

    log_warnings

    data
  end

  def error_message
    errors.map { |e| e[1] }.join(", ")
  end

  def error_codes
    errors.map { |e| e[0] }
  end

  def log_warnings
    EbayRequest.log_warn(@callname, @warnings.inspect)
  end
end
