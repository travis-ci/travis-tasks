$LOAD_PATH << File.expand_path("../../../../", __FILE__)

require "travis/tasks"
require "travis/support"
require "travis/support/exceptions/reporter"
require "travis/tasks/helpers/reporting"
require "travis/tasks/sidekiq"

$stdout.sync = true
Travis.logger.info("** Setting up Sidekiq **")

Travis::Tasks::Helpers::Reporting.setup
Travis::Exceptions::Reporter.start

Travis::Tasks::Sidekiq.setup

require "travis/addons/campfire"
require "travis/addons/email"
require "travis/addons/flowdock"
require "travis/addons/github_status"
require "travis/addons/hipchat"
require "travis/addons/irc"
require "travis/addons/pusher"
require "travis/addons/webhook"
