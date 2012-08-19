require 'bundler/setup'
require 'travis/tasks'

$stdout.sync = true

module Travis
  class Tasks
    class Cli < ::Thor
      namespace 'travis:tasks'

      desc 'start', 'Consume tasks from the hub'
      def start
        ENV['ENV'] || 'development'
        preload_constants!
        Travis::Tasks.start
      end

      protected

        def preload_constants!
          require 'core_ext/module/load_constants'
          require 'travis'

          [Travis::Tasks, Travis].each do |target|
            target.load_constants!(:skip => [/::AssociationCollection$/])
          end
        end
    end
  end
end

