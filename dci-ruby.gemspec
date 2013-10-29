# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "dci-ruby/version"

Gem::Specification.new do |s|
  s.name        = "dci-ruby"
  s.version     = DCI::VERSION
  s.authors     = ["Lorenzo Tello"]
  s.email       = ["ltello8a@gmail.com"]
  s.homepage    = "http://github.com/ltello/dci-ruby"
  s.summary     = "Make DCI paradigm available to Ruby applications by enabling developers defining contexts subclassing the class DCI::Context. You define roles inside the definition. Match roles and player objects in context instantiation."
  s.description = "Make DCI paradigm available to Ruby applications"
  s.licenses = ["MIT"]

  s.rubyforge_project = "dci-ruby"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec", "~> 2.0"
  # s.add_runtime_dependency "rest-client"
end
