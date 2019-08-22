require 'action_mailer'

module Travis
  module Addons
    module Billing
      module Mailer
        class BillingMailer < ActionMailer::Base
          append_view_path File.expand_path('../views', __FILE__)

          helper Mailer::Helpers

          def charge_failed(receivers, subscription, owner, charge, event, invoice, cc_last_digits)
            @subscription, @owner, @charge, @event = subscription, owner, charge, event
            subject = "Travis CI: Charging Your Credit Card Failed"
            mail(from: travis_email, to: receivers, subject: subject, template_path: 'billing_mailer')
          end

          def invoice_payment_succeeded(receivers, subscription, owner, _charge, _event, invoice, cc_last_digits)
            @invoice = InvoicePresenter.new(subscription, owner, invoice, cc_last_digits)
            subject = 'Travis CI: Your Invoice'
            download_attachment invoice.fetch(:pdf_url)
            mail(from: travis_email, to: receivers, subject: subject, template_path: 'billing_mailer')
          end

          def subscription_cancelled(receivers, subscription, owner, charge, event, invoice, cc_last_digits)
            @subscription = subscription
            subject = "Travis CI: Cancellation confirmed"
            mail(from: travis_email, to: receivers, subject: subject, template_path: 'billing_mailer')
          end

          private

            def travis_email
              "Travis CI <#{from_email}>"
            end

            def from_email
              "success@travis-ci.com"
            end

            class AttachmentNotFound < StandardError; end

            def download_attachment(url)
              conn = Faraday.new do |c|
                c.use FaradayMiddleware::FollowRedirects
                c.adapter Faraday.default_adapter
              end
              response = conn.get(url)
              if response.status == 200 && match = response.headers['Content-Disposition'].match(%r{attachment;\s*filename=\"?([\w\.]+)\"?})
                attachments[match[1]] = response.body
              else
                raise AttachmentNotFound, "Couldn't get attachment from #{url}: Status #{response.status} Headers: #{response.headers.inspect}"
              end
            end

          class InvoicePresenter
            attr_reader :cc_last_digits

            def initialize(subscription, owner, invoice, cc_last_digits)
              @subscription = subscription
              @owner = owner
              @invoice = invoice
              @cc_last_digits = cc_last_digits
            end

            def account_name
              @owner.fetch(:name)
            end

            def account_login
              @owner.fetch(:login)
            end

            def company
              @subscription.fetch(:company)
            end

            def address
              @subscription.fetch(:address)
            end

            def city
              @subscription.fetch(:city)
            end

            def state
              @subscription.fetch(:state)
            end

            def post_code
              @subscription.fetch(:post_code)
            end

            def country
              @subscription.fetch(:country)
            end

            def vat_id
              @subscription.fetch(:vat_id)
            end

            def full_name
              @subscription.values_at(:first_name, :last_name).compact.join(' ')
            end

            def amount_due
              @invoice.fetch(:amount_due) / 100.0
            end

            def created_at
              Time.parse(@invoice.fetch(:created_at))
            end

            def invoice_id
              @invoice.fetch(:invoice_id)
            end

            def current_period_start
              Time.at(@invoice.fetch(:current_period_start))
            end

            def current_period_end
              Time.at(@invoice.fetch(:current_period_end))
            end

            def plan
              @invoice.fetch(:plan)
            end

            def pdf_url
              @invoice.fetch(:pdf_url)
            end
          end
        end
      end
    end
  end
end
