module EbayRequest::Xml
  private

  def parse(response)
    MultiXml.parse(response)
  end

  def process(response, callname)
    response["#{callname}Response"].tap do |r|
      raise EbayRequest::Error if r.nil?

      ack = r["ack"] || r["Ack"]

      unless ack == "Success" || (ack == "Warning" && options[:ignore_warnings])
        raise build_ebay_error(r)
      end
    end
  end

  def error_codes_for(_r)
    []
  end

  def build_ebay_error(r)
    EbayRequest::Error.new(
      error_message_for(r),
      r,
      error_codes_for(r)
    )
  end
end
