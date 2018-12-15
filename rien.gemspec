require './lib/rien'

Gem::Specification.new do |s|
  s.name                     = 'rien'
  s.version                  = Rien::VERSION
  s.required_ruby_version    = '>=2.2.6'
  s.date                     = Time.now.strftime('%Y-%m-%d')
  s.summary                  = 'Ruby IR Encoding'
  s.description              = 'Encode your Ruby code for distribution'
  s.authors                  = ['CodeRemixer']
  s.email                    = ['dsh0416@gmail.com']
  s.require_paths            = ['lib']
  s.bindir                   = ['bin']
  s.executables              = ['rien']
  s.files                    = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec|.resources)/}) } \
    - %w(README.md CODE_OF_CONDUCT.md CONTRIBUTING.md Gemfile Rakefile my_general.gemspec .gitignore .rspec .codeclimate.yml .rubocop.yml .travis.yml logo.png Rakefile Gemfile)
  s.homepage                 = 'https://github.com/coderemixer/rien'
  s.metadata                 = { 'issue_tracker' => 'https://github.com/coderemixer/rien/issues' }
  s.license                  = 'Apache-2.0'
  s.add_runtime_dependency     'ruby-progressbar', '~> 1.9'
end
