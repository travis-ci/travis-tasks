source 'https://rubygems.org'

ruby '1.9.3', engine: 'jruby', engine_version: '1.7.5'

gem 'travis-support',  github: 'travis-ci/travis-support'

gem 'sidekiq'
gem 'gh',              github: 'rkh/gh'
gem 'sentry-raven',    github: 'getsentry/raven-ruby'
gem 'rollout',         github: 'jamesgolick/rollout', :ref => 'v1.1.0'
gem 'newrelic_rpm',    '~> 3.3.2'
gem 'aws-sdk'
gem 'roadie'
gem "hashr"
gem "metriks"
gem "addressable"
gem "faraday"
gem "irc-notify"

group :test do
  gem "rspec",        '~> 2.14'
  gem "guard"
  gem "guard-bundler"
  gem "guard-rspec"
end
