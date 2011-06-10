# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{cron_wrapper}
  s.version = "0.0.11"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bryan Taylor"]
  s.cert_chain = ["/home/bryan/gem_private_key/gem-public_cert.pem"]
  s.date = %q{2011-03-03}
  s.default_executable = %q{cron_wrapper}
  s.description = %q{A gem that provides useful features for running ruby or Rails scripts with cron}
  s.email = %q{btaylor39 @nospam@ csc.com}
  s.executables = ["cron_wrapper"]
  s.extra_rdoc_files = ["bin/cron_wrapper", "lib/cron_wrapper.rb"]
  s.files = ["Manifest", "Rakefile", "bin/cron_wrapper", "lib/cron_wrapper.rb", "spec/cron_wrapper_spec.rb", "spec/spec_helper.rb", "cron_wrapper.gemspec"]
  s.homepage = %q{http://rubyisbeautiful.com}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Cron_wrapper"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{cron_wrapper}
  s.rubygems_version = %q{1.3.7}
  s.signing_key = %q{/home/bryan/gem_private_key/gem-private_key.pem}
  s.summary = %q{features: locking to prevent resource contention, standard logging, optional rails integration}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
