source 'https://rubygems.org'

ruby '1.9.3', engine: 'jruby', engine_version: '1.7.12'

gem 'travis-support',  github: 'travis-ci/travis-support', branch: 'sf-te'

gem 'sidekiq',         '~> 2.17.0'
gem 'gh',              github: 'travis-ci/gh'
gem 'sentry-raven'
gem 'rollout',         github: 'jamesgolick/rollout', :ref => 'v1.1.0'
gem 'newrelic_rpm',    '~> 3.3.2'
gem 'aws-sdk'
gem 'actionmailer',    '~> 3.2.18'
gem 'roadie'
gem 'metriks'
gem 'metriks-librato_metrics'
gem 'hashr'
gem 'multi_json'
gem 'pusher'

group :test do
  gem 'rspec',        '~> 2.14.0'
  gem 'mocha',        '~> 0.10.0'
  gem 'webmock',      '~> 1.8.0'
  gem 'guard'
  gem 'guard-rspec'
end

group :production do
  gem 'foreman'
end
