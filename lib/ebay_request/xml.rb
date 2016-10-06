module EbayRequest::Xml
  private

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

  def split_errors_and_warnings(errs)
    errors = []
    warnings = []

    errs.each do |severity, code, message|
      if severity == "Warning"
        warnings << [code.to_i, message]
      else
        errors << [code.to_i, message]
      end
    end

    [errors, warnings]
  end

  # Parse response error, return array of [severity, code, message]
  def errors_for(_r)
    raise NotImplementedError, "Implement #{self.class.name}#errors_for"
  end
end
