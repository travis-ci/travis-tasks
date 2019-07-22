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

          def invoice_payment_succeeded(receivers, subscription, owner, charge, event, invoice, cc_last_digits)
            @subscription, @owner, @invoice, @cc_last_digits = subscription, owner, invoice, cc_last_digits
            subject = "Travis CI: Your Invoice"
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
              response = Faraday.get(url)
              if response.status == 200 && match = response.headers['Content-Disposition'].match(%r{attachment;\s*filename=\"?([\w\.]+)\"?})
                attachments[match[1]] = response.body
              else
                raise AttachmentNotFound, "Couldn't get attachment from #{url}: Status #{response.status} Headers: #{response.headers.inspect}"
              end
            end
        end
      end
    end
  end
end
