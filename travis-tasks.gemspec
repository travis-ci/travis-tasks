Gem::Specification.new do |s|
  s.name        = 'travis-tasks'
  s.version     = '0.0.1'
  s.authors     = ['Travis CI GmbH']
  s.email       = 'contact+travis-tasks@travis-ci.org'
  s.summary     = 'Tasks for Travis!'
  s.description = s.summary + '  Wow!'
  s.homepage    = 'https://github.com/travis-ci/travis-tasks'
  s.license     = 'MIT'

  s.files         = `git ls-files -z`.split("\x0")
  s.require_paths = %w(lib)
end
