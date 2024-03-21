source 'https://rubygems.org'

ruby '3.2.2'

gem 'travis-logger',     git: 'https://github.com/travis-ci/travis-logger'
gem 'travis-exceptions', git: 'https://github.com/travis-ci/travis-exceptions'
gem 'travis-metrics',    git: 'https://github.com/travis-ci/travis-metrics'
gem 'travis-config',    git: 'https://github.com/travis-ci/travis-config'
#TODO update branch 'travis-github_apps/ga-ext_access' against master
gem 'travis-github_apps', git: 'https://github.com/travis-ci/travis-github_apps', branch: 'dt-e3-0-update'
gem 'travis-rollout', git: 'https://github.com/travis-ci/travis-rollout'

gem 'metriks',                 git: 'https://github.com/travis-ci/metriks'
gem 'metriks-librato_metrics', git: 'https://github.com/travis-ci/metriks-librato_metrics'

gem 'sidekiq',         '~> 7'
gem 'redis-namespace'
gem 'sentry-ruby'
gem 'keen'

#TODO confirm that gh/master has all features gh/enterprise-3.0 had
gem 'gh',                  git: 'https://github.com/travis-ci/gh'

gem 'aws-sdk'
gem 'actionmailer'
gem 'roadie'
gem 'roadie-rails'
gem 'multi_json'
gem 'intercom', '~> 3.8.0'

gem 'faraday'

gem "activesupport"
gem "actionpack"
gem "railties"

gem 'net-smtp', require: false
gem 'net-imap', require: false
gem 'net-pop', require: false
gem 'globalid', '~> 1.0'
gem 'rexml'
gem 'matrix'

group :test do
  gem 'rspec'
  gem 'mocha', '~> 2.0.4', :require => false
  gem 'webmock'
  gem 'guard'
  gem 'guard-rspec'
  gem 'capybara'
end

group :production do
  gem 'foreman'
end

gem "connection_pool", "~> 2.2"
