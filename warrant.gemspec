# frozen_string_literal: true

require_relative "lib/warrant/version"

Gem::Specification.new do |spec|
  spec.name = "warrant"
  spec.version = Warrant::VERSION
  spec.authors = "Warrant"
  spec.email = "hello@warrant.dev"

  spec.summary = "Warrant Ruby Library"
  spec.description = "Ruby library for the Warrant API at https://warrant.dev."
  spec.homepage = "https://github.com/warrant-dev/warrant-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/warrant-dev/warrant-ruby"
  spec.metadata["changelog_uri"] = "https://github.com/warrant-dev/warrant-ruby/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://docs.warrant.dev/"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
