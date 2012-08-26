source :rubygems

# ruby 'jruby-1.6.7', :engine => 'jruby', :engine_version => '1.6.7'
# ruby '1.9.3', :engine => 'jruby', :engine_version => '1.7.0.preview1'
ruby '1.9.3', :engine => 'jruby', :engine_version => '1.7.0.preview2'

gem 'travis-core',        :git => 'git://github.com/travis-ci/travis-core'
gem 'travis-support',     :git => 'git://github.com/travis-ci/travis-support'

gem 'hubble',             :git => 'git://github.com/roidrage/hubble'
gem 'newrelic_rpm',       '~> 3.3.2'

gem 'hot_bunnies',        '~> 1.3.4'
gem 'jruby-openssl',      '~> 0.7.4'

group :test do
  gem 'rspec',            '~> 2.7.0'
  gem 'mocha',            '~> 0.10.0'
  gem 'webmock',          '~> 1.8.0'
  gem 'guard'
  gem 'guard-rspec'
end
