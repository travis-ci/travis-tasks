ENV['RAILS_ENV'] = ENV['ENV'] = 'test'

RSpec.configure do |c|
  c.before(:each) { Time.now.utc.tap { | now| Time.stubs(:now).returns(now) } }
end

require 'travis/task'
require 'travis/addons'
require 'travis/support/testing/webmock'
require 'travis/testing'
require 'travis/config'
require 'payloads'

ActionMailer::Base.delivery_method = :test

require 'mocha'
require 'gh'

include Mocha::API

RSpec.configure do |c|
  c.mock_with :mocha
  c.alias_example_to :fit, :focused => true
  c.filter_run :focused => true
  c.run_all_when_everything_filtered = true
  c.backtrace_clean_patterns.clear

  c.include Travis::Support::Testing::Webmock

  c.before :each do
    Travis.config.oauth2 ||= {}
    Travis.config.oauth2.scope = 'public_repo,user'
    GH.reset
  end
end

module Kernel
  def capture_stdout
    out = StringIO.new
    $stdout = out
    yield
    return out.string
  ensure
    $stdout = STDOUT
  end
end
