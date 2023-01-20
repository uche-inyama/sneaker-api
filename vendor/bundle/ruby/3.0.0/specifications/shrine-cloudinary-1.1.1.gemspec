# -*- encoding: utf-8 -*-
# stub: shrine-cloudinary 1.1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "shrine-cloudinary".freeze
  s.version = "1.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Janko Marohni\u0107".freeze]
  s.date = "2019-11-21"
  s.email = ["janko.marohnic@gmail.com".freeze]
  s.homepage = "https://github.com/shrinerb/shrine-cloudinary".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.1".freeze)
  s.rubygems_version = "3.2.3".freeze
  s.summary = "Provides Cloudinary storage for Shrine.".freeze

  s.installed_by_version = "3.2.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<shrine>.freeze, [">= 3.0.0.rc", "< 4"])
    s.add_runtime_dependency(%q<cloudinary>.freeze, ["~> 1.12"])
    s.add_runtime_dependency(%q<down>.freeze, ["~> 5.0"])
    s.add_runtime_dependency(%q<http>.freeze, [">= 3.2", "< 5"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
    s.add_development_dependency(%q<dotenv>.freeze, [">= 0"])
  else
    s.add_dependency(%q<shrine>.freeze, [">= 3.0.0.rc", "< 4"])
    s.add_dependency(%q<cloudinary>.freeze, ["~> 1.12"])
    s.add_dependency(%q<down>.freeze, ["~> 5.0"])
    s.add_dependency(%q<http>.freeze, [">= 3.2", "< 5"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<minitest>.freeze, [">= 0"])
    s.add_dependency(%q<dotenv>.freeze, [">= 0"])
  end
end
