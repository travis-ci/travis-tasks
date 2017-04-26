require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/module/aliasing'
require 'logger'

module Travis
  module Logging
    class << self
      def configure(*args, &block)
        require 'travis/support/logger'
        puts '[Deprecation] Travis::Logging.configure is deprecated. Use Travis::Logger.configure instead.'
        Logger.configure(*args, &block)
      end

      def included(base)
        base.extend(ClassMethods)
      end

      def wrap(type, name, args, options = {})
        Travis.logger.send(type || :info, prepend_header("about to #{name}#{format_arguments(args)}", options)) unless options[:only] == :after
        result = yield
        Travis.logger.send(type || :debug, prepend_header("done: #{name}", options)) unless options[:only] == :before
        result
      end

      def prepend_header(line, options = {})
        options[:log_header] ?  "[#{options[:log_header]}] #{line}" : line
      end

      private

        def format_arguments(args)
          args.empty? ? '' : "(#{args.map { |arg| format_argument(arg).inspect }.join(', ')})"
        end

        def format_argument(arg)
          if arg.is_a?(Hash) && arg.key?(:log) && arg[:log].size > 80
            arg = arg.dup
            arg[:log] = "#{arg[:log][0..80]} ..."
          end
          arg
        end
    end

    module ClassMethods
      def log_header(&block)
        block ? @log_header = block : @log_header
      end

      def log(name, options = {})
        define_method(:"#{name}_with_log") do |*args, &block|
          options[:log_header] ||= self.log_header
          Travis::Logging.wrap(options[:as], name, options[:params].is_a?(FalseClass) ? [] : args, options) do
            send(:"#{name}_without_log", *args, &block)
          end
        end
        alias_method_chain name, 'log'
      end
    end

    delegate :logger, :to => Travis

    [:fatal, :error, :warn, :info, :debug].each do |level|
      define_method(level) do |*args|
        message, options = *args
        if logger.method(level).arity == -2
          options ||= {}
          options[:log_header] ||= self.log_header
          logger.send(level, message, options)
        else
          logger.send(level, message)
        end
      end
    end

    def log_exception(exception)
      message = "#{exception.class.name}: #{exception.message}\n"
      message << exception.backtrace.join("\n") if exception.backtrace
      error(message, log_header: log_header)
    rescue Exception => e
      puts '--- FATAL ---'
      puts 'an exception occured while logging an exception'
      puts e.message, e.backtrace
      puts exception.message, exception.backtrace
    end

    def log_header
      self.class.log_header ? instance_eval(&self.class.log_header) : self.class.name.split('::').last.downcase
    end
  end
end
