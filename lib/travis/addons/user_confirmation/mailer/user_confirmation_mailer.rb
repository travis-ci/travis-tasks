# frozen_string_literal: true

require 'action_mailer'

module Travis
  module Addons
    module UserConfirmation
      module Mailer
        class UserConfirmationMailer < ActionMailer::Base
          append_view_path File.expand_path('views', __dir__)

          layout 'contact_email'

          def account_activated(*params)
            receivers = params[0]
            options = params[1]
            @owner, = options.values_at(:owner)
            subject = 'Travis CI: Your account has been activated!'
            mail(from: from, to: to(receivers), subject: subject,
                 template_path: 'user_confirmation_mailer')
          end

          def confirm_account(*params)
            receivers = params[0]
            options = params[1]
            @owner, @confirmation_url, @token_valid_to = options.values_at(:owner, :confirmation_url, :token_valid_to)
            subject = 'Travis CI: Confirm your account.'
            mail(from: from, to: to(receivers), subject: subject,
                 template_path: 'user_confirmation_mailer')
          end

          private

          def filter_receivers(receivers)
            receivers = receivers.flatten.uniq.compact
            receivers.reject { |email| email.include?('[') || email.include?(' ') || email.ends_with?('.home') }
          end

          def from
            "Travis CI <#{from_email}>"
          end

          def from_email
            config.emails&.user_confirmation_from || "no-reply@#{config.host_domain}"
          end

          def to(receivers)
            filter_receivers(receivers).first
          end

          def config
            Travis.config
          end
        end
      end
    end
  end
end
