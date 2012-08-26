require 'multi_json'

require 'travis'
require 'travis/support'

$stdout.sync = true

module Travis
  class Tasks
    extend Exceptions::Handling
    include Logging

    QUEUES = ['tasks', 'tasks.log']

    class << self
      def start
        setup
        new.subscribe
      end

      protected

        def setup
          Travis::Async.enabled = true
          Travis.config.update_periodically

          Travis::Exceptions::Reporter.start
          Travis::Notification.setup

          Travis::Amqp.config = Travis.config.amqp
          Travis::Mailer.setup
          # Travis::Features.start

          GH::DefaultStack.options[:ssl] = Travis.config.ssl

          NewRelic.start if File.exists?('config/newrelic.yml')
        end
    end

    def subscribe
      info 'Subscribing to amqp ...'
      QUEUES.each do |queue|
        info "Subscribing to #{queue}"
        Travis::Amqp::Consumer.new(queue).subscribe(:ack => true, &method(:receive))
      end
    end

    def receive(message, payload)
      if payload = decode(payload)
        Travis.uuid = payload.delete('uuid')
        handle(payload['type'], payload['data'], payload['options'])
      end
    rescue Exception => e
      puts "!!!FAILSAFE!!! #{e.message}", e.backtrace
    ensure
      message.ack
    end

    protected

      def handle(type, data, options)
        timeout do
          const = "Travis::Task::#{type.camelize}".constantize
          task = const.new(data, options)
          task.run
        end
      end
      rescues :handle, :from => Exception

      def timeout(&block)
        Timeout::timeout(60, &block)
      end

      def decode(payload)
        MultiJson.decode(payload)
      rescue StandardError => e
        error "[#{Thread.current.object_id}] [decode error] payload could not be decoded with engine #{MultiJson.engine.to_s} (#{e.message}): #{payload.inspect}"
        nil
      end
  end
end

