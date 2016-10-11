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
    make_a_boom unless success?
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

  def make_a_boom
    error = errors.find { |e| e[2] }
    raise error.last.new(error[1], self, [error[0]]) if error
    raise EbayRequest::Error.new(error_message, self, error_codes)
  end
end
