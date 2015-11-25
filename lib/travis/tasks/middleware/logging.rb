module Travis
  module Tasks
    module Middleware
      class Logging
        def call(worker, message, queue, &block)
          time = Benchmark.ms do
            yield
          end
        ensure
          uuid, _, _, payload, params = *message['args']
          data = Hash.new.tap do |data|
            data['type'] = queue
            if payload['build']
              data['build'] = payload['build']['id']
            elsif message['build_id']
              data['build'] = payload['build_id']
            end

            if payload['repository']
              data['repo'] = payload['repository']['slug']
            end

            data['event'] = params['event'] if params['event']
            data['uuid'] = uuid
            data['job'] = payload['id'] if params['event'] && params['event'] =~ /^job/
            data['time'] = "%.3f" % (time/1000) if time
            data['jid'] = message['jid']

            if payload['pull_request']
              data['pull_request'] = 'yes'
              data['pull_request_number'] = payload['pull_request_number']
            else
              data['pull_request'] = 'no'
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
