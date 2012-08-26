# EM::APNS

Persistent connections pool to APN service 

## Installation

Add this line to your application's Gemfile:

    gem 'em-apns'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install em-apns

## Usage
1. Create config file `config/em-apns.yml`
```ruby
cert: path/to/cert.pem
key: path/to/key.pem
pool: 4
```
2. Start the daemon `em-apns start -d` from the root folder of your app (`tmp/sockets` and `tmp/pids` are required, also `daemons` gem required for running process in background)
3. Send notification from your app (for non rails apps path to sock file is required: `EM::APNS.sock = path/to/sock/file` )
```ruby
EM::APNS.send_notification(token, alert: alert, custom: data)
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
