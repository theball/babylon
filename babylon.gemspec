Gem::Specification.new do |s|
  s.name = %q{babylon}
  s.version = "0.0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Julien Genestoux, Astro"]
  s.date = %q{2009-03-09}
  s.default_executable = %q{babylon}
  s.description = %q{Babylon is a framework to create EventMachine based XMPP External Components in Ruby.}
  s.email = %q{babylon@notifixio.us}
  s.executables = ["babylon"]
  s.extra_rdoc_files = ["README.rdoc", "lib/babylon/xpath_helper.rb", "lib/babylon/runner.rb", "lib/babylon/component_connection.rb", "lib/babylon/client_connection.rb", "lib/babylon/router.rb", "lib/babylon/base/view.rb", "lib/babylon/base/controller.rb", "lib/babylon/xmpp_connection.rb", "lib/babylon.rb", "CHANGELOG", "bin/babylon"]
  s.files = ["README.rdoc", "spec/config.yaml", "spec/xpath_helper_spec.rb", "spec/component_connection_spec.rb", "spec/client_connection_spec.rb", "spec/xmpp_connection_spec.rb", "spec/shared_spec.rb", "lib/babylon/xpath_helper.rb", "lib/babylon/runner.rb", "lib/babylon/component_connection.rb", "lib/babylon/client_connection.rb", "lib/babylon/router.rb", "lib/babylon/base/view.rb", "lib/babylon/base/controller.rb", "lib/babylon/xmpp_connection.rb", "lib/babylon.rb", "CHANGELOG", "templates/babylon/config/config.yaml", "templates/babylon/config/boot.rb", "templates/babylon/config/initializers/README.rdoc", "templates/babylon/config/routes.yaml", "templates/babylon/app/controllers/README.rdoc", "templates/babylon/app/views/README.rdoc", "templates/babylon/app/models/README.rdoc", "templates/babylon/script/component", "templates/babylon/script/generate", "Rakefile", "bin/babylon", "Manifest", "babylon.gemspec"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/julien51/babylon/}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Babylon", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{babylon}
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{Babylon is a framework to create EventMachine based XMPP External Components in Ruby.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<eventmachine>, [">= 0"])
      s.add_runtime_dependency(%q<log4r>, [">= 0"])
      s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
    else
      s.add_dependency(%q<eventmachine>, [">= 0"])
      s.add_dependency(%q<log4r>, [">= 0"])
      s.add_dependency(%q<nokogiri>, [">= 0"])
    end
  else
    s.add_dependency(%q<eventmachine>, [">= 0"])
    s.add_dependency(%q<log4r>, [">= 0"])
    s.add_dependency(%q<nokogiri>, [">= 0"])
  end
end
