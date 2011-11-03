# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{cron_wrapper}
  s.version = "0.0.12"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Bryan Taylor}]
  s.cert_chain = [%q{/Users/bryan/.gem_credentials/gem-public_cert.pem}]
  s.date = %q{2011-11-03}
  s.description = %q{A gem that provides useful features for running ruby or Rails scripts with cron}
  s.email = %q{btaylor39 @nospam@ csc.com}
  s.executables = [%q{cron_wrapper}]
  s.extra_rdoc_files = [%q{bin/cron_wrapper}, %q{lib/cron_wrapper.rb}]
  s.files = [%q{Manifest}, %q{Rakefile}, %q{bin/cron_wrapper}, %q{cron_wrapper.gemspec}, %q{lib/cron_wrapper.rb}, %q{spec/cron_wrapper_spec.rb}, %q{spec/spec_helper.rb}]
  s.homepage = %q{http://github.com/rubyisbeautiful}
  s.rdoc_options = [%q{--line-numbers}, %q{--inline-source}, %q{--title}, %q{Cron_wrapper}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{cron_wrapper}
  s.rubygems_version = %q{1.8.6}
  s.signing_key = %q{/Users/bryan/.gem_credentials/gem-private_key.pem}
  s.summary = %q{features: locking to prevent resource contention, standard logging, optional rails integration}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
