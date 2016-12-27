class EbayRequest::Response
  extend Dry::Initializer::Mixin

  param :callname
  param :data
  param :errors_data
  param :fatal_errors

  def success?
    ack = data["ack"] || data["Ack"]
    %w(Success Warning).include?(ack)
  end

  def data!
    make_a_boom unless success?
    log_warnings
    data
  end

  def errors
    severity("Error")
  end

  def warnings
    severity("Warning")
  end

  def severity(severity)
    Hash[errors_data.map { |s, c, m| [c.to_i, m] if s == severity }.compact]
  end

  def log_warnings
    return if warnings.empty?
    EbayRequest.log_warn(callname, warnings.inspect)
  end

  def error_class
    fatal_code = (errors.keys.map(&:to_i) & fatal_errors.keys).first
    fatal_errors[fatal_code] || EbayRequest::Error
  end

  def make_a_boom
    raise error_class.new(errors.values.join(", "), errors)
  end
end
