lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ashiba/version'

Gem::Specification.new do |spec|
  spec.name          = 'ashiba'
  spec.version       = Ashiba::VERSION
  spec.license       = 'Apache-2.0'
  spec.authors       = ['Thomas Heinen']
  spec.email         = ['theinen@tecracer.de']

  spec.summary       = 'Ashiba is another simple scaffolding tool'
  spec.description   = 'Use Ashiba to generate directory hierarchies according to templates'
  spec.homepage      = 'https://github.com/tecracer/ashiba'

  spec.files         = Dir['lib/**/**/**']
  spec.files        += Dir['bin/**/*']
  spec.files        += Dir['templates/**/**/**']
  spec.files        += ['README.md', 'CHANGELOG.md']

  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7'
  spec.metadata              = { 'rubygems_mfa_required' => 'true' }

  spec.add_development_dependency "bump", "~> 0.9"
  spec.add_development_dependency 'mdl', '~> 0.4'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop-rspec'

  spec.add_dependency 'hashie', '~> 3.5'
  spec.add_dependency 'highline', '~> 1.7'
  spec.add_dependency 'thor', '>= 0.20', '< 2.0'
end
