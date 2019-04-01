require 'keen'

module Travis
  class Task
    class Keenio < Struct.new(:type, :status, :payload)
      def publish(keen = Keen)
        Keen.publish(:notifications, data)
      rescue Keen::HttpError => e
        Travis.logger.warn "task=keen exception=#{e.class} message=\"#{e.message}\""
      end

      def data
        {
          type:       type,
          status:     status,
          repository: repo_data,
          owner:      owner_data,
          build:      build_data
        }
      end

      def repo_data
        {
          id:   repo[:id],
          slug: repo[:slug]
        }
      end

      def owner_data
        {
          id:    owner[:id],
          type:  owner[:type],
          login: owner[:login]
        }
      end

      def build_data
        {
          id:    build[:id],
          type:  build[:type]
        }
      end

      def repo
        payload[:repository] || {}
      end

      def owner
        payload[:owner] || {}
      end

      def build
        payload[:build] || {}
      end
    end
  end
end
