# frozen_string_literal: true

require_relative "lib/openfigi_ruby/version"

Gem::Specification.new do |spec|
  spec.name = "openfigi_ruby"
  spec.version = OpenfigiRuby::VERSION
  spec.authors = ["Phong Si"]
  spec.email = []

  spec.summary = "Ruby client for the OpenFIGI V3 API"
  spec.description = "Maps financial identifiers (ISIN, CUSIP, ticker, etc.) to FIGIs via the OpenFIGI V3 API. Supports bulk mapping, keyword search, and filtering."
  spec.homepage = "https://github.com/phongsi/openfigi_ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["documentation_uri"] = "https://www.rubydoc.info/github/phongsi/openfigi_ruby"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "webmock", "~> 3.0"
  spec.add_development_dependency "yard", "~> 0.9"
  spec.add_development_dependency "webrick", "~> 1.0"
end
