# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{babylon}
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Julien Genestoux", "Astro"]
  s.date = %q{2009-02-13}
  s.description = %q{Babylon is a framework to create EventMachine based XMPP External Components in Ruby. }
  s.email = %q{babylon@notifixio.us}
  s.files = ["README.rdoc", "lib/babylon.rb", "lib/babylon/base/controller.rb", "lib/babylon/base/view.rb", "lib/babylon/component_connection.rb", "lib/babylon/client_connection.rb", "lib/babylon/router.rb", "lib/babylon/runner.rb", "lib/babylon/xmpp_connection.rb", "bin/babylon", "spec", "templates", "templates/babylon", "templates/babylon/app", "templates/babylon/app/controllers/README.rdoc", "templates/babylon/app/models/README.rdoc", "templates/babylon/app/views/README.rdoc", "templates/babylon/config", "templates/babylon/config/routes.yaml", "templates/babylon/config/config.yaml", "templates/babylon/config/boot.rb", "templates/babylon/scripts", "templates/babylon/scripts/component", "templates/babylon/scripts/generate" ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/julien51/babylon/}
  # s.rubyforge_project = %q{babylon}
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{Babylon is a framework to create EventMachine based XMPP External Components in Ruby. }
  s.executables << 'babylon'

  s.add_dependency(%q<nokogiri>)
  s.add_dependency(%q<eventmachine>)
  
end

