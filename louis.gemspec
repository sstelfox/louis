# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'louis/version'

Gem::Specification.new do |spec|
  spec.name          = 'louis'
  spec.version       = Louis::VERSION
  spec.authors       = ['Sam Stelfox']
  spec.email         = ['sstelfox@bedroomprogrammers.net']
  spec.summary       = %q{Library for looking up the the vendor associated with a MAC address.}
  spec.description   = %q{There is a public registry maintained by the IANA that is required to be used by all vendors operating in certains spaces. Ethernet, Bluetooth, and Wireless device manufacturers are all assigned unique prefixes. This database is available publicly online and can be used to identify the manufacturer of these devices. This library provides an easy mechanism to perform these lookups.}
  spec.homepage      = 'https://github.com/sstelfox/louis'
  spec.license       = 'AGPL-3.0'

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.required_ruby_version = '>= 2.1'

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '>= 1.17'
  spec.add_development_dependency 'coveralls', '~> 0.8'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_development_dependency 'pry', '~> 0.12'
  spec.add_development_dependency 'rdoc', '~> 6.1'
  spec.add_development_dependency 'simplecov', '~> 0.16'
  spec.add_development_dependency 'yard', '~> 0.9'
end
