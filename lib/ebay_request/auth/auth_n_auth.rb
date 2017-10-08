# frozen_string_literal: true

class EbayRequest::Auth::AuthNAuth < EbayRequest::Trading
  attr_writer :session_id

  def session_id
    @session_id ||=
      response!("GetSessionID", RuName: config.runame)["SessionID"]
  end

  def uid
    raw_info["EIASToken"]
  end

  def info
    {
      user_id:    raw_info["UserID"],
      auth_token: auth_token[0],
      email:      raw_info["Email"],
      full_name:  full_name,
      first_name: parsed_name[0],
      last_name:  parsed_name[1],
      eias_token: raw_info["EIASToken"],
      country:    raw_info["RegistrationAddress"].try(:[], "Country"),
    }
  end

  def credentials
    { token: auth_token[0], expires_at: auth_token[1] }
  end

  def auth_token
    [
      raw_token_data["eBayAuthToken"],
      Time.parse(raw_token_data["HardExpirationTime"]).to_i,
    ]
  end

  def raw_info
    @raw_info ||=
      response!(
        "GetUser",
        RequesterCredentials: { eBayAuthToken: auth_token[0] },
        DetailLevel: "ReturnAll",
      )["User"]
  end

  def ebay_login_url(ruparams = {})
    params = [
      "SignIn",
      "RuName=#{CGI.escape(config.runame)}",
      "SessID=#{CGI.escape(session_id)}",
    ]
    ruparams = CGI.escape(ruparams.map { |k, v| "#{k}=#{v}" }.join("&"))
    params << "ruparams=#{CGI.escape(ruparams)}"

    "#{signin_endpoint}?#{params.join('&')}"
  end

  private

  def parsed_name
    @parsed_name ||= (full_name || "").split(" ", 2)
  end

  def full_name
    @full_name ||= raw_info["RegistrationAddress"].try(:[], "Name")
  end

  def raw_token_data
    @raw_token_data ||= response!("FetchToken", SessionID: session_id)
  end

  def signin_endpoint
    URI.parse(
      with_sandbox("https://signin%{sandbox}.ebay.com/ws/eBayISAPI.dll"),
    )
  end
end
