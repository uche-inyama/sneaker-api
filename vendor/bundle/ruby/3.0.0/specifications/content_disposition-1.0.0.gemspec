# -*- encoding: utf-8 -*-
# stub: content_disposition 1.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "content_disposition".freeze
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jonathan Rochkind".freeze]
  s.date = "2018-12-18"
  s.email = ["jrochkind@chemheritage.org".freeze]
  s.homepage = "https://github.com/shrinerb/content_disposition".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3".freeze)
  s.rubygems_version = "3.2.3".freeze
  s.summary = "Ruby gem to create HTTP Content-Disposition headers with proper escaping/encoding of filenames".freeze

  s.installed_by_version = "3.2.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<bundler>.freeze, ["~> 1.17"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.17"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
  end
end
