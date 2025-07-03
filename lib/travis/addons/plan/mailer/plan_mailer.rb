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
            @signup_url = signup_url(owner)
            subject = 'Welcome to Travis CI!'
            mail(from: from, to: receivers, subject: subject, template_path: 'plan_mailer')
          end

          def builds_not_allowed(receivers, owner, params)
            @owner = owner
            @plan_url = plan_url(owner)
            @purchase_url = purchase_url(owner)
            @repository_url = params.fetch(:repository_url)
            subject = 'Builds have been temporarily disabled'
            mail(from: from, to: receivers, subject: subject, template_path: 'plan_mailer')
          end

          def credit_balance_state(receivers, owner, params)
            @owner_login = owner[:login]
            @plan_url = plan_url(owner)
            @state = params.fetch(:state) # integer number of percentage usage
            @purchase_url = purchase_url(owner)
            @signup_url = signup_url(owner)
            subject = 'Credits balance state notification'
            mail(from: from, to: receivers, subject: subject, template_path: 'plan_mailer')
          end

          def private_credits_for_public(receivers, owner, params)
            @owner = owner
            @plan_url = plan_url(owner)
            @settings_url = settings_url(owner)
            @signup_url = signup_url(owner)
            @repository_url = params.fetch(:repository_url)
            @renewal_date = params.fetch(:renewal_date)
            subject = 'Builds have been temporarily disabled'
            mail(from: from, to: receivers, bcc: filter_receivers(receivers), subject: subject, template_path: 'plan_mailer')
          end

          def plan_change_reminder(receivers, owner, params)
            @owner = owner
            @signup_url = signup_url(owner)
            @plan = params.fetch(:plan, '').to_s
            @annual = params.fetch(:annual, false)
            @credits = params.fetch(:credits, 0)
            @price = params.fetch(:price, 0)
            @due_date = params.fetch(:due_date, Time.now)
            subject = 'Plan Change Reminder'
            mail(from: from, to: receivers, subject: subject, template_path: 'plan_mailer')
          end

          def credit_card_expiration_reminder(receivers, owner, params)
            @owner = owner
            @payment_details_url = payment_details_url(owner)
            @plan = params.fetch(:plan, '').to_s
            @cc_expiration_date = params.fetch(:cc_expiration_date, '')
            subject = 'Your credit card expires soon'
            mail(from: from, to: receivers, subject: subject, template_path: 'plan_mailer')
          end

          def end_trial_reminder(receivers, owner, params)
            @owner = owner
            @name = owner[:name] || owner[:login]
            @due_date = Date.parse(params.fetch(:due_date, Date.today).to_s);
            @plan = params.fetch(:plan, '').to_s
            @price = "#{params.fetch(:price, 0)/100}$"

            @days_count = (Date.parse(@due_date.to_s) - Date.today).to_i
            @days = "in #{@days_count} days"
            @days = 'tomorrow' if @days_count == 1
            @days = 'today' unless @days_count
            @signup_url = signup_url(owner)
            @skip_signup_section = true
            subject = "Your Free Trial Is Ending Soon – Automatic Subscription on #{@due_date}"
            mail(from: from, to: receivers, subject: subject, template_path: 'plan_mailer')
          end

          def shared_plan_no_admin(receivers, owner, params)
            @receiver = params.fetch(:receiver)[:login]
            @donor = params.fetch(:donor)
            @recipients = params.fetch(:recipients)
            @plan_share_url = plan_share_url(@donor)
            subject = 'Review Your Plan Sharing Settings'
            mail(from: from, to: @recipients, subject: subject, template_path: 'plan_mailer')
          end

          def csv_export_ready(receivers, owner, params)
            @owner = owner
            @report = params.fetch(:report)
            subject = "Travis CI: Your Credits Consumption Report is Ready"

            mail(from: from, to: receivers, subject: subject, template_path: 'plan_mailer')
          end
          private

            def from
              "Travis CI <#{from_email}>"
            end

            def from_email
              config.emails && config.emails.plan_from || "no-reply@#{config.host_domain}"
            end

            def config
              Travis.config
            end

            def user?(owner)
              type = owner[:billing_slug] || owner[:owner_type]
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

            def signup_url(owner)
              return "https://#{config.host}/account" if user?(owner)
              "https://#{config.host}/organizations/#{owner[:login]}"
            end

            def payment_details_url(owner)
              return "https://#{config.host}/account/#{config.payment_details_path}" if user?(owner)
              "https://#{config.host}/organizations/#{owner[:login]}/#{config.payment_details_path}"
            end

            def filter_receivers(receivers)
              receivers = receivers.flatten.uniq.compact
              receivers.reject { |email| email.include?("[") || email.include?(" ") || email.ends_with?(".home") }
            end

            def plan_share_url(owner)
              owner[:owner_type] == 'User' ? "https://#{config.host}/account/plan/share" :
              "https://#{config.host}/organizations/#{owner[:login]}/plan/share"
            end
        end
      end
    end
  end
end
