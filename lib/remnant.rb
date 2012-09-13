require 'statsd'

require 'remnant/base'
require 'remnant/configuration'
require 'remnant/discover'
require 'remnant/rails'
require 'remnant/version'

require 'remnant/railtie' if defined?(::Rails::Railtie)
