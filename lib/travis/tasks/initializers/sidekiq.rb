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

require "travis/tasks/notifiers/campfire"
require "travis/tasks/notifiers/email"
require "travis/tasks/notifiers/flowdock"
require "travis/tasks/notifiers/github_status"
require "travis/tasks/notifiers/hipchat"
require "travis/tasks/notifiers/irc"
require "travis/tasks/notifiers/pusher"
require "travis/tasks/notifiers/webhook"
