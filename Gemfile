source 'https://rubygems.org'

ruby '2.1.6'

gem 'travis-support',  github: 'travis-ci/travis-support'
gem 'travis-config',  '~> 1.0.0'

gem 'sidekiq',         '~> 4.0.0'
gem 'redis-namespace'
gem 'gh',              github: 'travis-ci/gh'
gem 'sentry-raven'
gem 'rollout',         github: 'jamesgolick/rollout', :ref => 'v1.1.0'
gem 'newrelic_rpm',    '~> 3.3.2'
gem 'aws-sdk'
gem 'actionmailer',    '~> 3.2.18'
gem 'roadie'
gem 'roadie-rails',    '~> 1.0'
gem 'metriks'
gem 'metriks-librato_metrics'
gem 'multi_json'
gem 'pusher', '~> 0.14.5'
gem 'jemalloc'

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
