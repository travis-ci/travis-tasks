require 'action_mailer'
require 'i18n'

module Travis
  module Addons
    module Email
      module Mailer
        require 'travis/addons/email/mailer/helpers'
        require 'travis/addons/email/mailer/build'
      end

      require 'travis/addons/email/task'

      class << self
        def setup
          mailer = ActionMailer::Base
          mailer.delivery_method = :smtp
          mailer.smtp_settings = Travis.config.smtp
          ActionMailer::Base.append_view_path("#{base_dir}/views")
          I18n.load_path += Dir["#{base_dir}/locales/**/*.yml"]
          I18n.enforce_available_locales = false
        end

        def base_dir
          File.expand_path('../email/mailer', __FILE__)
        end
      end
    end
  end
end
