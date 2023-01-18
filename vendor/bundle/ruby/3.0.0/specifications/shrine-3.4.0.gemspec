# -*- encoding: utf-8 -*-
# stub: shrine 3.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "shrine".freeze
  s.version = "3.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/shrinerb/shrine/issues", "changelog_uri" => "https://github.com/shrinerb/shrine/blob/master/CHANGELOG.md", "documentation_uri" => "https://shrinerb.com", "mailing_list_uri" => "https://discourse.shrinerb.com", "source_code_uri" => "https://github.com/shrinerb/shrine" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Janko Marohni\u0107".freeze]
  s.date = "2021-06-14"
  s.description = "Shrine is a toolkit for file attachments in Ruby applications. It supports\nuploading, downloading, processing and deleting IO objects, backed by various\nstorage engines. It uses efficient streaming for low memory usage.\n\nShrine comes with a high-level interface for attaching uploaded files to\ndatabase records, saving their location and metadata to a database column, and\ntying them to record's lifecycle. It natively supports background jobs and\ndirect uploads for fully asynchronous user experience.\n".freeze
  s.email = ["janko.marohnic@gmail.com".freeze]
  s.homepage = "https://shrinerb.com".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3".freeze)
  s.rubygems_version = "3.2.3".freeze
  s.summary = "Toolkit for file attachments in Ruby applications".freeze

  s.installed_by_version = "3.2.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<down>.freeze, ["~> 5.1"])
    s.add_runtime_dependency(%q<content_disposition>.freeze, ["~> 1.0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 11.1"])
    s.add_development_dependency(%q<minitest>.freeze, ["~> 5.8"])
    s.add_development_dependency(%q<mocha>.freeze, ["~> 1.11"])
    s.add_development_dependency(%q<rack>.freeze, ["~> 2.0"])
    s.add_development_dependency(%q<http-form_data>.freeze, ["~> 2.2"])
    s.add_development_dependency(%q<rack-test_app>.freeze, [">= 0"])
    s.add_development_dependency(%q<mimemagic>.freeze, [">= 0.3.2"])
    s.add_development_dependency(%q<marcel>.freeze, [">= 0"])
    s.add_development_dependency(%q<ruby-filemagic>.freeze, ["~> 0.7"])
    s.add_development_dependency(%q<mime-types>.freeze, [">= 0"])
    s.add_development_dependency(%q<mini_mime>.freeze, ["~> 1.0"])
    s.add_development_dependency(%q<fastimage>.freeze, [">= 0"])
    s.add_development_dependency(%q<mini_magick>.freeze, ["~> 4.0"])
    s.add_development_dependency(%q<ruby-vips>.freeze, ["~> 2.0"])
    s.add_development_dependency(%q<aws-sdk-s3>.freeze, ["~> 1.69"])
    s.add_development_dependency(%q<aws-sdk-core>.freeze, ["~> 3.23"])
    s.add_development_dependency(%q<rexml>.freeze, [">= 0"])
    s.add_development_dependency(%q<dry-monitor>.freeze, [">= 0"])
    s.add_development_dependency(%q<activesupport>.freeze, ["~> 6.0"])
    s.add_development_dependency(%q<sequel>.freeze, [">= 0"])
    s.add_development_dependency(%q<activerecord>.freeze, ["~> 6.0"])
    s.add_development_dependency(%q<sqlite3>.freeze, ["~> 1.4"])
  else
    s.add_dependency(%q<down>.freeze, ["~> 5.1"])
    s.add_dependency(%q<content_disposition>.freeze, ["~> 1.0"])
    s.add_dependency(%q<rake>.freeze, [">= 11.1"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.8"])
    s.add_dependency(%q<mocha>.freeze, ["~> 1.11"])
    s.add_dependency(%q<rack>.freeze, ["~> 2.0"])
    s.add_dependency(%q<http-form_data>.freeze, ["~> 2.2"])
    s.add_dependency(%q<rack-test_app>.freeze, [">= 0"])
    s.add_dependency(%q<mimemagic>.freeze, [">= 0.3.2"])
    s.add_dependency(%q<marcel>.freeze, [">= 0"])
    s.add_dependency(%q<ruby-filemagic>.freeze, ["~> 0.7"])
    s.add_dependency(%q<mime-types>.freeze, [">= 0"])
    s.add_dependency(%q<mini_mime>.freeze, ["~> 1.0"])
    s.add_dependency(%q<fastimage>.freeze, [">= 0"])
    s.add_dependency(%q<mini_magick>.freeze, ["~> 4.0"])
    s.add_dependency(%q<ruby-vips>.freeze, ["~> 2.0"])
    s.add_dependency(%q<aws-sdk-s3>.freeze, ["~> 1.69"])
    s.add_dependency(%q<aws-sdk-core>.freeze, ["~> 3.23"])
    s.add_dependency(%q<rexml>.freeze, [">= 0"])
    s.add_dependency(%q<dry-monitor>.freeze, [">= 0"])
    s.add_dependency(%q<activesupport>.freeze, ["~> 6.0"])
    s.add_dependency(%q<sequel>.freeze, [">= 0"])
    s.add_dependency(%q<activerecord>.freeze, ["~> 6.0"])
    s.add_dependency(%q<sqlite3>.freeze, ["~> 1.4"])
  end
end
