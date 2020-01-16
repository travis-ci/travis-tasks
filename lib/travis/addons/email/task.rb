require 'mail'

module Travis
  module Addons
    module Email

      # Sends out build notification emails using ActionMailer.
      class Task < Travis::Task
        def recipients
          @recipients ||= params[:recipients].select { |email| valid?(email) }
        end

        def broadcasts
          broadcasts = params[:broadcasts]
        end

        def type
          :finished_email
        end

        private

          def process(timeout)
            send_email if recipients.any?
          rescue Net::SMTPServerBusy => e
            error("Could not send email to: #{recipients} (error: #{e.message})")
            raise unless e.message =~ /Bad recipient address syntax/ || e.message =~ /Recipient address rejected/
          rescue StandardError => e
            error("Could not send email to: #{recipients}")
            log_exception(e)
            raise
          end

          def send_email
            Mailer::Build.finished_email(payload, recipients, broadcasts).deliver
            info "type=email repo=#{repository_slug(payload)} build=#{build_id(payload)} status=sent msg='email sent' #{recipients.map { |r| 'email=' + obfuscate_email_address(r) }.join(' ')}"
          end

          def build_id(data)
            build = Hashr.new(data[:build])
            build.id
          rescue
            "nil"
          end

          def repository_slug(data)
            repository = Hashr.new(data[:repository])
            repository.slug
          rescue
            "nil"
          end

          def valid?(email)
            return false if email =~ /\.local$/
            mail = Mail::Address.new(email)
            mail.domain && mail.address == email && mail.domain.split('.').size > 1
          rescue Exception => e
            false
          end

          def obfuscate_email_address(add)
            match_data = add.match /^(?<name>[^@]+)@(?<domain>.+?)\.(?<tld>[^\.]+)$/
            return add unless match_data

            name       = match_data[:name]
            domain     = match_data[:domain]
            tld        = match_data[:tld]
            name       = name[0,3]   + '...' if name.length > 3
            domain     = domain[0,3] + '...' if domain.length > 3

            name + '@' + domain + '.' + tld
          end
      end
    end
  end
end
