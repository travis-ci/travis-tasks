module Travis
  module Tasks
    class Worker
      include ::Sidekiq::Worker

      sidekiq_options dead: false

      attr_accessor :retry_count

      def perform(_, target, method, payload, params = {})
        const  = constantize(target)
        params = JSON.parse(params) if params.is_a?(String) && params.length > 0
        params = params.merge(retry_count: retry_count.to_i)
        puts "PERFORM: method:#{method.inspect}\n\n, ply:#{payload.inspect}\n\nparm: #{params.inspect}"
        const.send(method, payload, params)
      end

      private

        def constantize(str)
          str.tr!('"','')
          str.split('::').inject(Kernel) do |const, name|
            const.const_get(name)
          end
        end
    end
  end

  module Async
    module Sidekiq
      Worker = Travis::Tasks::Worker
    end
  end
end
