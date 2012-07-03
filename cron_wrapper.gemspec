# -*- encoding: utf-8 -*-
require File.expand_path('../lib/cron_wrapper/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Bryan Taylor"]
  gem.email         = [ "bcptaylor@gmail.com" ]
  gem.description   = %q{ A gem that provides useful features for running ruby or Rails scripts with cron }
  gem.summary       = %q{ features: locking to prevent resource contention, standard logging, optional rails integration }
  gem.homepage      = "http://github.com/rubyisbeautiful/cron_wrapper"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "cron_wrapper"
  gem.require_paths = ["lib"]
  gem.version       = CronWrapper::VERSION

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rspec-rails'
end
