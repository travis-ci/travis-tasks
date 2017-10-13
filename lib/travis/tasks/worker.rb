module Travis
  module Tasks
    class Worker
      include ::Sidekiq::Worker

      sidekiq_options dead: false

      attr_accessor :retry_count

      def perform(_, target, method, payload, params = {})
        const  = constantize(target)
        params = params.merge(retry_count: retry_count.to_i)
        const.send(method, payload, params)
      end

      private

        def constantize(str)
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
