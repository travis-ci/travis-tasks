source 'https://rubygems.org'

ruby '2.4.2'

gem 'travis-logger',     git: 'https://github.com/travis-ci/travis-logger'
gem 'travis-exceptions', git: 'https://github.com/travis-ci/travis-exceptions'
gem 'travis-metrics',    git: 'https://github.com/travis-ci/travis-metrics'
gem 'travis-config',   '~> 1.1.0'
gem 'travis-github_apps', git: 'https://github.com/travis-ci/travis-github_apps'

gem 'metriks',                 git: 'https://github.com/travis-ci/metriks'
gem 'metriks-librato_metrics', git: 'https://github.com/travis-ci/metriks-librato_metrics'

gem 'sidekiq',         '~> 4.0.0'
gem 'redis-namespace'
gem 'sentry-raven'
gem 'keen'

gem 'jemalloc', git: 'https://github.com/joshk/jemalloc-rb'

gem 'gh'
gem 'aws-sdk'
gem 'actionmailer',    '~> 3.2.18'
gem 'roadie'
gem 'roadie-rails',    '~> 1.0'
gem 'multi_json'

gem 'faraday'
gem 'faraday_middleware'

group :test do
  gem 'rspec',         '~> 3.8'
  gem 'mocha',         '~> 0.10.0'
  gem 'webmock',       '~> 1.8.0'
  gem 'guard'
  gem 'guard-rspec'
end

group :production do
  gem 'foreman'
end
