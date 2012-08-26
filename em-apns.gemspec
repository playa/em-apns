# -*- encoding: utf-8 -*-
require File.expand_path('../lib/em-apns/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Yuri Barbashov"]
  gem.email         = ["lolcoltd@gmail.com"]
  gem.description   = %q{EventMachine-driven Apple Push Notifications Sender daemon}
  gem.summary       = %q{EventMachine-driven Apple Push Notifications Sender daemon}
  gem.homepage      = "https://github.com/playa/em-apns"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "em-apns"
  gem.require_paths = ["lib"]
  gem.version       = EM::APNS::VERSION
  
  gem.add_dependency "eventmachine", ">= 1.0.0.beta.3"
  gem.add_dependency "json"

  gem.add_development_dependency "rspec", "~> 2.6.0"
end
