require './lib/rien/version'

Gem::Specification.new do |s|
  s.name        = 'rien'
  s.version     = Rien::VERSION
  s.summary     = 'Ruby IR Encoding'
  s.description = 'Encode your Ruby code for distribution'

  s.platform              = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.7.0'

  s.license = 'Apache-2.0'

  s.authors  = ['CodeRemixer']
  s.email    = ['dsh0416@gmail.com']
  s.homepage = 'https://github.com/coderemixer/rien'

  s.files        = Dir['bin/**/*', 'lib/**/*', 'LICENSE', 'README.md']
  s.require_path = 'lib'

  s.bindir      = 'bin'
  s.executables = ['rien']

  s.metadata = {
    'bug_tracker_uri' => 'https://github.com/coderemixer/rien/issues'
  }

  s.add_runtime_dependency 'ruby-progressbar', '~> 1.9'
  s.add_development_dependency 'rake', '~> 13.0.1'
  s.add_development_dependency 'minitest', '~> 5.14.1'
  s.add_development_dependency 'ci_reporter_minitest', '~> 1.0.0'
end
