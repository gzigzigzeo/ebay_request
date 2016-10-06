# EbayRequest

eBay API request interface.

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
EbayRequest.warn_logger = Logger.new("ebay-request-warn.log") # Primary log used otherwise
```

```ruby
EbayRequest::Finding.new.response("findItemsByKeywords", keywords: "abc")
EbayRequest::Shopping.new.response("GetSingleItem", ItemID: "252261544055")
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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gzigzigzeo/ebay_request.
