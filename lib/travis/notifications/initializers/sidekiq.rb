$LOAD_PATH << File.expand_path("../../../../", __FILE__)

require "travis/notifications"
require "travis/support"
require "travis/support/exceptions/reporter"
require "travis/notifications/helpers/reporting"
require "travis/notifications/sidekiq"

$stdout.sync = true
Travis.logger.info("** Setting up Sidekiq **")

Travis::Notifications::Helpers::Reporting.setup
Travis::Exceptions::Reporter.start

Travis::Notifications::Sidekiq.setup

require "travis/notifications/notifiers"
