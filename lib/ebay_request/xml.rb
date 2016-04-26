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
        raise EbayRequest::Error, error_message_for(r)
      end
    end
  end
end
