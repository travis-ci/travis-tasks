source 'https://rubygems.org'

ruby '2.6.10'

gem 'travis-logger',     git: 'https://github.com/travis-ci/travis-logger'
gem 'travis-exceptions', git: 'https://github.com/travis-ci/travis-exceptions'
gem 'travis-metrics',    git: 'https://github.com/travis-ci/travis-metrics'
gem 'travis-config',     '~> 1.1.0'
gem 'travis-github_apps', git: 'https://github.com/travis-ci/travis-github_apps', branch: 'ga-ext_access'
gem 'travis-rollout',    '~> 0.0.2'

gem 'metriks',                 git: 'https://github.com/travis-ci/metriks'
gem 'metriks-librato_metrics', git: 'https://github.com/travis-ci/metriks-librato_metrics'

gem 'sidekiq',         '~> 6'
gem 'redis-namespace'
gem 'sentry-raven'
gem 'keen'

gem 'jemalloc', git: 'https://github.com/travis-ci/jemalloc-rb', branch: 'upgrade-rake'

gem 'gh',                  git: 'https://github.com/travis-ci/gh', ref: 'enterprise-3.0'
gem 'aws-sdk'
gem 'actionmailer', "~> 5.2.7.1"
gem 'roadie'
gem 'roadie-rails'
gem 'multi_json'
gem 'intercom', '~> 3.8.0'

gem 'faraday', '~> 1.0'
gem 'faraday_middleware'

gem "activesupport", ">= 5.2.7.1"
gem "actionpack", ">= 5.2.7.1"
gem "railties", ">= 5.2.7.1"

group :test do
  gem 'rspec'
  gem 'mocha', '~> 1.10.0'
  gem 'webmock'
  gem 'guard'
  gem 'guard-rspec'
  gem 'capybara'
end

group :production do
  gem 'foreman'
end

gem "connection_pool", "~> 2.2"
