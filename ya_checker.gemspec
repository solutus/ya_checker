# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ya_checker/version"

Gem::Specification.new do |s|
  s.name        = "ya_checker"
  s.version     = YaChecker::VERSION
  s.authors     = ["Sergey Staskov"]
  s.email       = ["staskovs@yandex.ru"]
  s.homepage    = ""
  s.summary     = "checks url on particular position on yandex.search"
  s.description = "Checker retrieves search results for keyword from xml.yandex.ru and returns url from particular position."
  
  s.rubyforge_project = "ya_checker"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_development_dependency 'webmock'

  s.add_runtime_dependency("em-http-request", "1.0.2")
  s.add_runtime_dependency("em-synchrony", "1.0.1")
  s.add_runtime_dependency("nokogiri", "1.5.0")
end
