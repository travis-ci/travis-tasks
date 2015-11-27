require 'active_support/core_ext/string/inflections'

module Travis
  module Tasks
    module Middleware
      class Logging
        def call(worker, message, queue, &block)
          time = Benchmark.ms do
            yield
          end
        ensure
          uuid, notifier, _, payload, params = *message['args']
          data = Hash.new.tap do |data|
            data['queue'] = queue
            data['notifier'] = notifier.to_s.underscore.split('/')[2]
            if payload['build']
              data['build'] = payload['build']['id']
            elsif message['build_id']
              data['build'] = payload['build_id']
            end

            if payload['repository']
              data['repo'] = payload['repository']['slug']
            end

            data['uuid'] = uuid
            data['job'] = payload['id'] if params['event'] && params['event'] =~ /^job/
            data['time'] = "%.3f" % (time/1000) if time
            data['jid'] = message['jid']

            if payload['build'] && payload['build']['pull_request']
              data['event'] = 'pull_request'
              data['pull_request_number'] = payload['build']['pull_request_number']
            else
              data['event'] = 'push'
            end
          end
          log(data)
        end

        def log(data)
          Travis.logger.info(data.map {|k, v| "#{k}=#{v}" if v}.join(" "))
        end
      end
    end
  end
end
