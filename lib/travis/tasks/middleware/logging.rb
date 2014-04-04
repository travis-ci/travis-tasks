module Travis
  module Tasks
    module Middleware
      class Logging
        def call(worker, message, queue, &block)
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
          end
          log(data)
          yield
        end

        def log(data)
          Travis.logger.info(data.map {|k, v| "#{k}=#{v}"}.join(" "))
        end
      end
    end
  end
end
