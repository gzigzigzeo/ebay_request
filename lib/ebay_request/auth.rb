class EbayRequest::Auth < EbayRequest::Trading
  def session_id
    response("GetSessionID", RuName: config.runame)
  end

  def token(session_id)
    response("FetchToken", SessionID: session_id)
  end

  def user(auth_token)
    response("GetUser", RequesterCredentials: { eBayAuthToken: auth_token })
  end

  def ebay_login_url(session_id, ruparams = {})
    params = [
      "SignIn",
      "RuName=#{config.runame}",
      "SessID=#{session_id}"
    ]

    ruparams = CGI.escape(ruparams.map { |k, v| "#{k}=#{v}" }.join("&"))
    params << "ruparams=#{CGI.escape(ruparams)}"

    "#{signin_endpoint}?#{params.join('&')}"
  end

  private

  def signin_endpoint
    URI.parse(with_sandbox(
      "https://signin%{sandbox}.ebay.com/ws/eBayISAPI.dll"
    )))
  end
end
