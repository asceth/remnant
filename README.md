Remnant hooks into your Rails and discovers your hidden statistics.

##### Supports

* Rails 2.3.x


#### Install

```
$ [sudo] gem install remnant
```

```ruby
# For Rails 2.3.x
gem 'remnant'
```


#### Usage


Add an initializer to configure (or call configure during application startup):

```ruby
Remnant.configure do
  # hostname of statsd server
  host "https://remnant.statsd"

  # port of statsd server
  port 8125

  # app name or other unique key for multiple app usage
  tagged "custom"

  # environment of application, defaults to Rails.env
  # included in payload
  environment "production"
end
```


#### Author


Original author: John "asceth" Long
