Gem::Specification.new do |spec|
  spec.name        = '<%= name %>'
  spec.version     = '<%= version %>'
  spec.licenses    = ['Nonstandard']

  spec.summary     = '<%= summary %>'
  spec.description = '<%= description %>'
  spec.authors     = ['<%= author %>']
  spec.email       = ['<%= email %>']
  spec.homepage    = '<%= url %>'

  spec.files       = Dir.glob('templates/**/**', File::FNM_DOTMATCH)
  spec.files      += ['README.md', 'CHANGELOG.md']

  spec.required_ruby_version = '>= 2.4'

  spec.add_runtime_dependency('ashiba', '>= 0.5')
end
