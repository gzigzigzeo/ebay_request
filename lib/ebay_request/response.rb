# frozen_string_literal: true

class EbayRequest::Response
  extend Dry::Initializer

  param :callname
  param :data
  param :errors_data
  param :fatal_errors

  def success?
    ack = data["ack"] || data["Ack"]
    %w[Success Warning].include?(ack)
  end

  def data!
    raise error unless success?
    data
  end

  def errors
    severity("Error")
  end

  def warnings
    severity("Warning")
  end

  def severity(severity)
    errors_data.select { |error_item| error_item.severity == severity }
  end

  def error_class
    fatal_code = (errors.map(&:code) & fatal_errors.keys).first
    fatal_errors[fatal_code] || EbayRequest::Error
  end

  def error
    error_class.new(errors.join(", "), errors: errors, warnings: warnings)
  end
end
