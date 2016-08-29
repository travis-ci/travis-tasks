source 'https://rubygems.org'

ruby '2.3.1'

gem 'travis-support',  github: 'travis-ci/travis-support'
gem 'travis-config',   '~> 1.0.6'

gem 'sidekiq',         '~> 4.0.0'
gem 'redis-namespace'
gem 'sentry-raven'
gem 'metriks'
gem 'metriks-librato_metrics'

gem 'jemalloc', github: 'joshk/jemalloc-rb'

gem 'gh'
gem 'aws-sdk'
gem 'actionmailer',    '~> 3.2.18'
gem 'roadie'
gem 'roadie-rails',    '~> 1.0'
gem 'multi_json'

group :test do
  gem 'rspec',         '~> 2.14.0'
  gem 'mocha',         '~> 0.10.0'
  gem 'webmock',       '~> 1.8.0'
  gem 'guard'
  gem 'guard-rspec'
end

group :production do
  gem 'foreman'
end
