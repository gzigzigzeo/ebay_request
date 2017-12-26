# frozen_string_literal: true

require "spec_helper"

describe EbayRequest::IAFTokenManager do
  let(:config) do
    EbayRequest::Config.new.tap do |c|
      c.appid = "1"
      c.certid = "2"
    end
  end

  let(:refresh_response) { '{"access_token":"new_token","expires_in":7200}' }
  let!(:api) do
    stub_request(:post, "https://api.sandbox.ebay.com/identity/v1/oauth2/token")
      .with(
        body: { grant_type: "refresh_token", refresh_token: "refreshing" },
        basic_auth: %w[1 2],
      )
      .to_return(status: 200, body: refresh_response)
  end

  let(:access_expire)  { Time.now + 1 }
  let(:refresh_expire) { Time.now + 1 }
  let(:callback) { proc {} }

  subject do
    described_class.new(
      access_token:  "old_token",  access_token_expires_at:  access_expire,
      refresh_token: "refreshing", refresh_token_expires_at: refresh_expire,
      on_refresh: callback,
    )
  end

  before do
    Timecop.freeze
    allow(EbayRequest).to receive(:config).and_return(config)
    allow(callback).to receive(:call).with("new_token", Time.now + 7200)
  end

  after { Timecop.return }

  describe "#access_token" do
    context "with valid access_token" do
      it "returns access_token" do
        expect(subject.access_token).to eq("old_token")
        expect(api).not_to have_been_requested
      end
    end

    context "with expired access_token" do
      let(:access_expire)  { Time.now }

      it "gets and returns a new access token" do
        expect(subject.access_token).to eq("new_token")
        expect(api).to have_been_requested
      end
    end
  end

  describe "#refresh!" do
    context "with valid refresh token" do
      it "requests new token from API" do
        subject.refresh!
        expect(api).to have_been_requested
        expect(subject.access_token).to eq("new_token")
        expect(subject.access_token_expires_at).to eq(Time.now + 7200)
      end

      it "calls callback" do
        subject.refresh!
        expect(callback).to have_received(:call)
      end
    end

    context "with expired refresh token" do
      let(:refresh_expire)  { Time.now }

      it "raises exception" do
        expect { subject.refresh! }.to \
          raise_error(EbayRequest::IAFTokenManager::RefreshTokenExpired)
      end
    end

    context "with revoked refresh token" do
      let(:refresh_response) do
        '{"error":"invalid_grant","error_description":"this is fiasco"}'
      end

      it "raises exception" do
        expect { subject.refresh! }.to raise_error(
                                           EbayRequest::IAFTokenManager::RefreshTokenInvalid, "this is fiasco"
        )
      end
    end
  end
end
