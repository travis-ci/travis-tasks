require 'action_mailer'

module Travis
  module Addons
    module Gdpr
      module Mailer
        class GdprMailer < ActionMailer::Base
          append_view_path File.expand_path('../views', __FILE__)

          def export(receivers, user_name, export_url)
            @user_name = user_name
            @export_url = export_url
            mail(from: travis_email, to: receivers, subject: 'Your data report', template_path: 'gdpr_mailer')
          end

          def support_export(receivers, user_name, export_url)
            @user_name = user_name
            @export_url = export_url
            mail(from: travis_email, to: receivers, subject: 'User data report', template_path: 'gdpr_mailer')
          end

          def purge(receivers, request_date)
            @request_date = request_date
            mail(from: travis_email, to: receivers, subject: 'Your data was purged', template_path: 'gdpr_mailer')
          end

          private

          def travis_email
            "Travis CI <success@travis-ci.com>"
          end
        end
      end
    end
  end
end
