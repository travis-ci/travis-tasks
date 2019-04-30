require 'action_mailer'

module Travis
  module Addons
    module Migration
      module Mailer
        class MigrationMailer < ActionMailer::Base
          append_view_path File.expand_path('../views', __FILE__)

          def beta_confirmation(recepients, user_name, organizations)
            @user_name = user_name
            @organizations = organizations

            mail(
              from: travis_email,
              to: recepients,
              subject: "Your account, @#{user_name}, is ready to start migrating!",
              template_path: 'migration_mailer'
            )
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
