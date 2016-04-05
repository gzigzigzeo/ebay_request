module EbayRequest::Xml
  private

  def parse(response)
    MultiXml.parse(response)
  end

  def process(response, callname)
    response["#{callname}Response"].tap do |r|
      raise EbayRequest::Error if r.nil?

      if r["ack"] != "Success" && r["Ack"] != "Success"
        raise EbayRequest::Error, error_message_for(r)
      end
    end
  end
end
