
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "scenic/oracle_adapter/version"

Gem::Specification.new do |spec|
  spec.name          = "scenic-oracle_adapter"
  spec.version       = Scenic::OracleAdapter::VERSION
  spec.authors       = ["Chris Dinger"]
  spec.email         = ["chris@houseofding.com"]

  spec.summary       = %q{Oracle adapter for thoughtbot/scenic}
  spec.homepage      = "https://github.com/cdinger/scenic-oracle_adapter"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "scenic", "= 1.9.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", ">= 0.49.0"
  spec.add_development_dependency "ruby-oci8", "~> 2.2"
end
