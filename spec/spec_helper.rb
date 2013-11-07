$:.unshift(File.expand_path("../../lib", __FILE__))

RSpec.configure do |config|
  config.expect_with(:rspec) do |e|
    e.syntax = :expect
  end
end

require "support/payloads"
require "travis/notifications"
