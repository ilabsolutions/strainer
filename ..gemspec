$LOAD_PATH.append File.expand_path("lib", __dir__)
require "./identity"

Gem::Specification.new do |spec|
  spec.name = .::Identity.name
  spec.version = .::Identity.version
  spec.platform = Gem::Platform::RUBY
  spec.authors = ["Rishab Govind"]
  spec.email = ["rishab.govind@gmail.com"]
  spec.homepage = ""
  spec.summary = ""
  spec.license = "MIT"

  spec.metadata = {
    "source_code_uri" => "",
    "changelog_uri" => "/blob/master/CHANGES.md",
    "bug_tracker_uri" => "/issues"
  }


  spec.required_ruby_version = "~> 2.6"
  spec.add_dependency "runcom", "~> 5.0"
  spec.add_dependency "thor", "~> 0.20"
  spec.add_development_dependency "bundler-audit", "~> 0.6"
  spec.add_development_dependency "gemsmith", "~> 13.8"
  spec.add_development_dependency "pry", "~> 0.12"
  spec.add_development_dependency "pry-byebug", "~> 3.7"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.9"

  spec.files = Dir["lib/**/*"]
  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.executables << "."
  spec.require_paths = ["lib"]
end
