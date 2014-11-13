$:.push File.expand_path("../lib", __FILE__)
require "remnant/version"

Gem::Specification.new do |s|
  s.name        = "remnant"
  s.version     = Remnant::VERSION
  s.platform    = Gem::Platform::RUBY
  s.license     = 'MIT'
  s.authors     = ["John 'asceth' Long"]
  s.email       = ["machinist@asceth.com"]
  s.homepage    = "https://github.com/asceth/remnant"
  s.summary     = "Rails statistical discoverer"
  s.description = "Remnant - peering into your ruby apps and discovering statistics you never knew could be so awful..."

  s.rubyforge_project = "remnant"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'statsd-ruby', '~> 1.0', '>= 1.0.0'
end
