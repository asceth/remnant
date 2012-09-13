require 'statsd'

require 'remnant/base'
require 'remnant/configuration'
require 'remnant/rails'

require 'remnant/railtie' if defined?(::Rails::Railtie)
