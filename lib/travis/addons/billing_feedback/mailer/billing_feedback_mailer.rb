require 'action_mailer'

module Travis
  module Addons
    module BillingFeedback
      module Mailer
        class BillingFeedbackMailer < ActionMailer::Base
          append_view_path File.expand_path('../views', __FILE__)

          def user_feedback(_recipients, subscription, owner, user, feedback)
            @subscription, @owner, @user, @feedback = subscription, owner, user, feedback
            subject = "Subscription cancelled for #{owner[:login]}"
            mail(from: travis_email, to: travis_email, reply_to: @user[:email], subject: subject, template_path: 'feedback_mailer')
          end

          def changetofree_feedback(_recipients, subscription, owner, user, feedback)
            @subscription, @owner, @user, @feedback = subscription, owner, user, feedback
            subject = "Subscription changed to Free for #{owner[:login]}"
            mail(from: travis_email, to: travis_email, reply_to: @user[:email], subject: subject, template_path: 'feedback_mailer')
          end

          def cancellation_request(recipients, subscription, owner, user, feedback)
            @subscription, @owner, @user, @feedback = subscription, owner, user, feedback
            @admin_v2_link = admin_v2_url(owner)
            subject = "[TCI: CANCEL REQUEST] #{owner[:login]}."
            mail(from: travis_email, to: recipients, reply_to: @user[:email], subject: subject, template_path: 'feedback_mailer')
          end

          def notify_subscription_cancellations(recipients, cancellations)
            @cancellations = cancellations
            @admin_v2_links = {}
            @cancellations.each do |cancellation|
              @admin_v2_links["#{cancellation[:owner_id]}_#{cancellation[:owner_type]}"] = admin_v2_url({ owner_type: cancellation[:owner_type], id: cancellation[:owner_id] })
            end
            subject = '[Travis CI - Daily Cancellation List]'
            mail(from: travis_email, to: recipients, subject: subject, template_path: 'feedback_mailer')
          end

          private

            def travis_email
              "Travis CI <#{from_email}>"
            end

            def from_email
              "cancellations@travis-ci.com"
            end

            def admin_v2_url(owner)
              "#{Travis.config.admin_v2.url}/#{owner[:owner_type].downcase.pluralize}/#{owner[:id]}"
            end
        end
      end
    end
  end
end
