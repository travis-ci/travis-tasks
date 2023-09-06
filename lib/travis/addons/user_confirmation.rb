# frozen_string_literal: true

require 'action_mailer'

module Travis::Addons::UserConfirmation
  module Mailer
  end

  require 'travis/addons/user_confirmation/task'

  class << self
    def setup
      puts "USER CONFIRM setup"
      mailer = ActionMailer::Base
      mailer.delivery_method = :smtp
      mailer.smtp_settings = Travis.config.smtp.to_h
      ActionMailer::Base.append_view_path("#{base_dir}/views")
    end

    def base_dir
      File.expand_path('trial/mailer', __dir__)
    end
  end
end
