require_relative 'lib/oico/changelog/version'

Gem::Specification.new do |spec|
  spec.name          = 'oico-changelog'
  spec.version       = Oico::Changelog::VERSION
  spec.authors       = ['Oico']
  spec.email         = ['jufcandido@hotmail.com']

  spec.summary       = %q{Oico changelog}
  spec.description   = %q{A tool to automaticaly build a changelog}
  spec.homepage      = 'https://www.oico.com.br/'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'dotenv-rails', '~> 2.7'
end
