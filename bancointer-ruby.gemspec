# frozen_string_literal: true

require_relative "lib/bancointer/version"

Gem::Specification.new do |spec|
  spec.name = "bancointer-ruby"
  spec.version = Bancointer::VERSION
  spec.authors = ["Neri J Jakubowski Jr"]
  spec.email = ["neri@nerijunior.com"]

  spec.summary = "Gem Ruby para integração com as APIs do Banco Inter"
  spec.description = "Gem Ruby que facilita a integração com as APIs do Banco Inter, incluindo autenticação mTLS, OAuth 2.0, e gerenciamento automático de tokens."
  spec.homepage = "https://github.com/nerijunior/bancointer-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/nerijunior/bancointer-ruby"
  spec.metadata["changelog_uri"] = "https://github.com/nerijunior/bancointer-ruby/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_dependency "faraday", "~> 2.0"
  spec.add_dependency "faraday-multipart", "~> 1.0"
end
