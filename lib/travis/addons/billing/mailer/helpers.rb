
module Travis
  module Addons
    module Billing
      module Mailer
        module Helpers
          # Parses stripe event object according to the info it contains, it can vary if it's a plan update (proration) or only a payment
          def parse_subscription(event)
            if event[:lines][:subscriptions]
              event[:lines][:subscriptions].first
            else
              event[:lines][:data].find {|subscription| subscription[:id] == event[:subscription]}
            end
          end
        
          def set_period(event, period_frame ,subscription)
            event_object = parse_subscription(event)
            period = event_object[:period] if event_object
            puts Time.at(period[period_frame.to_sym])
            return Time.at(period[period_frame.to_sym]).utc.to_date unless period.nil?
            period_frame == 'start' ? subscription[:updated_at] : subscription[:valid_to]
          end        
        end
      end
    end
  end
end
