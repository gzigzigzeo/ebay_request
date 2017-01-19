require "spec_helper"

describe EbayRequest::Trading, "GetSuggestedCategories" do
  let(:config) do
    EbayRequest::Config.new.tap do |c|
      c.appid  = "1"
      c.certid = "2"
      c.devid  = "3"
      c.runame = "4"
    end
  end

  before do
    allow(EbayRequest).to receive(:config).and_return(config)
  end

  let(:headers) do
    {
      "X-Ebay-Api-App-Name" => "1",
      "X-Ebay-Api-Call-Name" => "GetSuggestedCategories",
      "X-Ebay-Api-Cert-Name" => "2",
      "X-Ebay-Api-Compatibility-Level" => "941",
      "X-Ebay-Api-Dev-Name" => "3",
      "X-Ebay-Api-Siteid" => "0"
    }
  end

  let(:request) do
    <<-XML.gsub(/\n?( +\| *)?/, "")
      |<?xml version="1.0" encoding="utf-8"?>
      |<GetSuggestedCategoriesRequest xmlns="urn:ebay:apis:eBLBaseComponents">
      |  <Query>Cool Thing</Query>
      |  <ErrorLanguage>en_US</ErrorLanguage>
      |  <MessageID>foobar</MessageID>
      |  <WarningLevel>Low</WarningLevel>
      |</GetSuggestedCategoriesRequest>
    XML
  end

  let(:successful_response) do
    <<-XML.gsub(/\n?( +\| *)?/, "")
      |<GetSuggestedCategoriesResponse xmlns="urn:ebay:apis:eBLBaseComponents">
      |  <CategoryCount>2</CategoryCount>
      |  <SuggestedCategoryArray>
      |    <SuggestedCategory>
      |      <Category>
      |        <CategoryID>100501</CategoryID>
      |        <CategoryName>Waste Things</CategoryName>
      |        <CategoryParentID>100500</CategoryParentID>
      |        <CategoryParentName>Things</CategoryParentName>
      |      </Category>
      |      <PercentItemFound>1</PercentItemFound>
      |    </SuggestedCategory>
      |    <SuggestedCategory>
      |      <Category>
      |        <CategoryID>100502</CategoryID>
      |        <CategoryName>Cool Things</CategoryName>
      |        <CategoryParentID>100500</CategoryParentID>
      |        <CategoryParentName>Things</CategoryParentName>
      |      </Category>
      |      <PercentItemFound>99</PercentItemFound>
      |    </SuggestedCategory>
      |  </SuggestedCategoryArray>
      |  <Ack>Success</Ack>
      |  <Timestamp>2016-04-18T12:12:26.600Z</Timestamp>
      |  <Version>1</Version>
      |</GetSuggestedCategoriesResponse>
    XML
  end

  let(:response_with_errors) do
    <<-XML.gsub(/\n?( +\| *)?/, "")
      |<GetSuggestedCategoriesResponse xmlns="urn:ebay:apis:eBLBaseComponents">
      |  <CategoryCount>0</CategoryCount>
      |  <SuggestedCategoryArray>
      |  </SuggestedCategoryArray>
      |  <Ack>Failure</Ack>
      |  <Build>1value</Build>
      |  <CorrelationID>foobar</CorrelationID>
      |  <Errors>
      |    <ErrorClassification>RequestError</ErrorClassification>
      |    <ErrorCode>11</ErrorCode>
      |    <LongMessage>Something got wrong</LongMessage>
      |    <SeverityCode>Error</SeverityCode>
      |    <ShortMessage>Ouch!</ShortMessage>
      |  </Errors>
      |  <Errors>
      |    <SeverityCode>Warning</SeverityCode>
      |    <ErrorCode>57</ErrorCode>
      |    <LongMessage>Some other warning</LongMessage>
      |  </Errors>
      |  <Timestamp>2016-04-18T12:12:26.600Z</Timestamp>
      |  <Version>1</Version>
      |</GetSuggestedCategoriesResponse>
    XML
  end

  it "sends request and parses response" do
    stub_request(:post, "https://api.sandbox.ebay.com/ws/api.dll")
      .with(body: request)
      .to_return(status: 200, body: successful_response)

    response = subject.response "GetSuggestedCategories",
                                Query:         "Cool Thing",
                                ErrorLanguage: "en_US",
                                MessageID:     "foobar",
                                WarningLevel:  "Low"

    expect(response).to be_success
    expect(response.errors).to eq({})
    expect(response.warnings).to eq({})

    expect(response.data!).to be
  end

  it "sends request and parses response with errors" do
    stub_request(:post, "https://api.sandbox.ebay.com/ws/api.dll")
      .with(body: request)
      .to_return(status: 200, body: response_with_errors)

    response = subject.response "GetSuggestedCategories",
                                Query:         "Cool Thing",
                                ErrorLanguage: "en_US",
                                MessageID:     "foobar",
                                WarningLevel:  "Low"

    expect(response).not_to be_success
    expect(response.errors).to eq 11 => "Something got wrong"
    expect(response.warnings).to eq 57 => "Some other warning"

    expect(EbayRequest).to_not receive(:log_warn)

    expect { response.data! }.to raise_error EbayRequest::Error,
                                             "Something got wrong"
  end
end
