require 'metriks'

module Travis
  module Tasks
    module Middleware
      class Metriks
        def call(worker, message, queue, &block)
          begin
            ::Metriks.meter("tasks.jobs.#{queue}").mark
            ::Metriks.timer("tasks.jobs.#{queue}.perform").time(&block)
          rescue Exception
            ::Metriks.meter("tasks.jobs.#{queue}.failure").mark
            raise
          end
        end
      end
    end
  end
end
