# frozen_string_literal: true

$LOAD_PATH.append File.expand_path('lib', __dir__)
require 'strainer/identity'

# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |spec|
  spec.name = Strainer::Identity.name
  spec.version = Strainer::Identity.version
  spec.platform = Gem::Platform::RUBY
  spec.authors = ['Rishab Govind']
  spec.email = ['rishab.govind@gmail.com']
  spec.homepage = 'https://github.com/ilabsolutions/strainer'
  spec.summary = 'Catch rails compatibility issues in a synvert-able way'
  spec.license = 'MIT'

  spec.metadata = {
    'source_code_uri' => 'https://github.com/ilabsolutions/strainer',
    'changelog_uri' => 'https://github.com/ilabsolutions/strainer/blob/master/CHANGES.md',
    'bug_tracker_uri' => 'https://github.com/ilabsolutions/strainer/issues'
  }

  spec.required_ruby_version = '>= 2.6.5'
  spec.add_dependency 'ougai', '~> 1.8.2'
  spec.add_dependency 'rails', '>= 6.0', '< 6.1'
  spec.add_dependency 'runcom', '~> 5.0'
  spec.add_dependency 'synvert', '~> 0.9.0'
  spec.add_dependency 'thor', '~> 0.20'

  spec.add_development_dependency 'bundler-audit', '~> 0.6'
  spec.add_development_dependency 'gemsmith', '~> 13.8'
  spec.add_development_dependency 'git-cop', '~> 3.5'
  spec.add_development_dependency 'pry', '~> 0.12'
  spec.add_development_dependency 'pry-byebug', '~> 3.7'
  spec.add_development_dependency 'rails', '>= 4.2', '< 6.1'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'rubocop', '~> 0.77'
  spec.add_development_dependency 'rubocop-performance', '~> 1.5'
  spec.add_development_dependency 'rubocop-rake', '~> 0.5'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.37'
  spec.add_development_dependency 'simplecov', '~> 0.16'
  spec.add_development_dependency 'sqlite3', '~> 1.4.2'

  spec.files = Dir['lib/**/*']
  spec.extra_rdoc_files = Dir['README*', 'LICENSE*']
  spec.executables << 'strainer'
  spec.require_paths = ['lib']
end
# rubocop:enable Metrics/BlockLength
