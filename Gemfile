source 'https://rubygems.org'

ruby '1.9.3', engine: 'jruby', engine_version: '1.7.4'

gem 'travis-core',     github: 'travis-ci/travis-core'
gem 'travis-support',  github: 'travis-ci/travis-support'
gem 'travis-sidekiqs', github: 'travis-ci/travis-sidekiqs', require: nil

gem 'sidekiq'
gem 'gh',              github: 'rkh/gh'
gem 'sentry-raven',    github: 'getsentry/raven-ruby'
gem 'rollout',         github: 'jamesgolick/rollout', :ref => 'v1.1.0'
gem 'newrelic_rpm',    '~> 3.3.2'
gem 'aws-sdk'
gem 'roadie'

group :test do
  gem 'rspec',        '~> 2.7.0'
  gem 'mocha',        '~> 0.10.0'
  gem 'webmock',      '~> 1.8.0'
  gem 'guard'
  gem 'guard-rspec'
end
