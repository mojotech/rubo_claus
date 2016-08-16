lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rubo_claus/version'

Gem::Specification.new do |s|
  s.name          = 'rubo_claus'
  s.version       = RuboClaus::VERSION
  s.date          = '2016-08-09'
  s.summary       = 'Ruby Method Pattern Matcher'
  s.description   = 'Define ruby methods with pattern matching much like Erlang/Elixir'
  s.authors       = ['Omid Bachari', 'Craig P Jolicoeur']
  s.email         = ['omid@mojotech.com', 'craig@mojotech.com']
  s.files         = `git ls-files`.split($/)
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]
  s.license       = 'MIT'
  s.homepage      = 'http://mojotech.github.io/rubo_claus/'

  s.add_development_dependency 'rake', '~> 0'
  s.add_development_dependency 'minitest', '>= 5.9'
  s.required_ruby_version = '>= 2.1'
end
