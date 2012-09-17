require 'rubygems'
require 'bundler'
Bundler.setup

require 'rspec'
require 'rr'

RSpec.configure do |config|
  config.mock_with :rr
end

require 'action_controller'
require 'active_support'

require 'remnant'

Dir["#{File.expand_path(File.dirname(__FILE__))}/support/*.rb"].map {|file| require(file)}

# for dependency reloading
ActiveSupport::Dependencies.autoload_paths << File.dirname(__FILE__) + '/app/'
