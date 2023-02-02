# EbayRequest

eBay XML API request interface.

> This gem is currently supported by the [ebaymag](https://ebaymag.com) team at [the corresponding fork](https://github.com/ebaymag/ebay_request). Please, send your issues and PR-s to that repository!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ebay_request'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ebay_request

## Usage

```ruby
# config/initializers/ebay_request.rb

secrets = Rails.application.secrets.ebay
raise "Set eBay credentials in secrets.yml" if secrets.blank?

EbayRequest.configure do |config|
  config.appid = secrets["appid"]
  config.certid = secrets["certid"]
  config.devid = secrets["devid"]
  config.runame = secrets["runame"]
  config.sandbox = secrets["sandbox"]
end

EbayRequest.logger = Logger.new("ebay-request.log")
EbayRequest.warn_logger = Logger.new("ebay-request-warn.log") # Not logged otherwise
EbayRequest.json_logger = GraylogProxy.new # Should receive #notify
```

```ruby
EbayRequest::Finding.new.response("findItemsByKeywords", keywords: "abc")
EbayRequest::Shopping.new.response("GetSingleItem", ItemID: "252261544055")
EbayRequest::Shopping.new(token: "...").response("AddItem", ...some data...)
```

## Using multiple key sets

```ruby
EbayRequest.configure do |config|
  config.appid = secrets["appid"]
  # And so on
  # ...
end

EbayRequest.configure(:sandbox) do |config|
  config.appid = secrets["appid"]
  # ...
  config.sandbox = true  
end

EbayRequest::Finding.new(env: :sandbox).response("findItemsByKeywords", keywords: "abc")
```

## OmniAuth strategy

If gem is configured somewhere at initializer (shown above):

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :ebay
end
```

If you want to use just strategy you can pass all the required options as `#provider` args ([see source](https://github.com/gzigzigzeo/ebay_request/blob/master/lib/omniauth/strategies/ebay.rb#L4)).

This strategy is for Auth'n'auth method only. For OAuth method see the [omniauth-ebay-oauth](https://github.com/evilmartians/omniauth-ebay-oauth) gem.


## Working with old XML and new REST API simultaneously

If you're planning to work with new eBay REST APIs, you will find that another kind of access tokens are required for working with these APIs.

Tokens obtained with Auth'n'auth only usable with eBay XML API, while tokens obtained with OAuth only usable with eBay REST API.

However, you can use new OAuth tokens to access old APIs by providing an access token in (not yet) documented HTTP header `X-EBAY-API-IAF-TOKEN`. This gem has builtin support for this.

To use it:

 1. Replace OmniAuth strategy from this gem to the strategy from the [omniauth-ebay-oauth](https://github.com/evilmartians/omniauth-ebay-oauth) gem.

    Most probably you will need to store and use both Auth'n'auth and OAuth tokens for a while to provide a smooth transition.

 2. For working with REST API and their tokens add the [ebay_api](https://github.com/nepalez/ebay_api/) gem to your application.

 3. Construct an `EbayAPI::TokenManager` instance with all OAuth tokens.

    See https://github.com/nepalez/ebay_api/#working-with-access-tokens

    Any object that responds to `refresh!` method and returns actual token from the `access_token` method will be fine too.

 4. Pass this token manager object in `:iaf_token_manager` option into the XML API constructor:

    ```ruby
    EbayRequest::Trading.new(
      token: auth_n_auth_token,
      iaf_token_manager: iaf_token_manager,
      siteid: 0,
    )
    ```

    You can pass both old token in `:token` option and new token manager in `:iaf_token_manager` option. Old tokens will be used if the token manager is `nil`.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gzigzigzeo/ebay_request.
