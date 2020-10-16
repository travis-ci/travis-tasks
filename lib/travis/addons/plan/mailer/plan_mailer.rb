require 'action_mailer'

module Travis
  module Addons
    module Plan
      module Mailer
        class PlanMailer < ActionMailer::Base
          append_view_path File.expand_path('../views', __FILE__)

          layout 'contact_email'

          def welcome(receivers, owner, params)
            @owner = owner
            @vcs_name = humanize_vcs_type(owner)
            @signup_url = signup_url(owner)
            @plan = params.fetch(:plan, 'Free Tier Plan').to_s
            subject = 'Welcome to Travis CI!'
            mail(from: from, to: to, reply_to: reply_to, bcc: filter_receivers(receivers), subject: subject, template_path: 'plan_mailer')
          end

          def builds_not_allowed(receivers, owner, params)
            @owner = owner
            @vcs_name = humanize_vcs_type(owner)
            @plan_url = plan_url(owner)
            @purchase_url = purchase_url(owner)
            @repository_url = params.fetch(:repository_url)
            subject = 'Builds have been temporarily disabled'
            mail(from: from, to: to, reply_to: reply_to, bcc: filter_receivers(receivers), subject: subject, template_path: 'plan_mailer')
          end

          def credit_balance_state(receivers, owner, params) # rubocop:disable Metrics/AbcSize
            Travis.logger.info("DEBUGXAXAX receivers: #{receivers.inspect}, owner: #{owner.inspect}, params: #{params}")
            @owner_login = owner[:login]
            @plan_url = plan_url(owner)
            @state = params.fetch(:state) # integer number of percentage usage
            @purchase_url = purchase_url(owner)
            @signup_url = signup_url(owner)
            subject = 'Credits balance state notification'
            mail(from: from, to: to, reply_to: reply_to, bcc: filter_receivers(receivers), subject: subject, template_path: 'plan_mailer')
          end

          def private_credits_for_public(receivers, owner, params)
            @owner = owner
            @vcs_name = humanize_vcs_type(owner)
            @plan_url = plan_url(owner)
            @settings_url = settings_url(owner)
            @repository_url = params.fetch(:repository_url)
            @renewal_date = params.fetch(:renewal_date)
            subject = 'Builds have been temporarily disabled'
            mail(from: from, to: to, reply_to: reply_to, bcc: filter_receivers(receivers), subject: subject, template_path: 'plan_mailer')
          end

          private

            def from
              "Travis CI <#{from_email}>"
            end

            def from_email
              config.email && config.email.trials_from || "trials@#{config.host}"
            end

            def to
              config.email && config.email.trials_to_placeholder || "trials@#{config.host}"
            end

            def reply_to
              "Travis CI Support <#{reply_to_email}>"
            end

            def reply_to_email
              config.email && config.email.reply_to || "support@#{config.host}"
            end

            def config
              Travis.config
            end

            def humanize_vcs_type(owner)
              owner[:vcs_type].gsub('User', '').gsub('Organization', '')
            end

            def user?(owner)
              type = owner[:billing_slug] || owner[:owner_type]
              Travis.logger.info("DEBUGXAXAX is user?: #{type.downcase} #{type.downcase == 'user'}")
              type.downcase == 'user'
            end

            def plan_url(owner)
              return "https://#{config.host}/account/#{config.plan_path}" if user?(owner)
              "https://#{config.host}/organizations/#{owner[:login]}/#{config.plan_path}"
            end

            def purchase_url(owner)
              return "https://#{config.host}/account/#{config.purchase_path}" if user?(owner)
              "https://#{config.host}/organizations/#{owner[:login]}/#{config.purchase_path}"
            end

            def settings_url(owner)
              return "https://#{config.host}/account/#{config.settnigs_path}" if user?(owner)
              "https://#{config.host}/organizations/#{owner[:login]}/#{config.settings_path}"
            end

            def filter_receivers(receivers)
              receivers = receivers.flatten.uniq.compact
              receivers.reject { |email| email.include?("[") || email.include?(" ") || email.ends_with?(".home") }
            end
        end
      end
    end
  end
end
