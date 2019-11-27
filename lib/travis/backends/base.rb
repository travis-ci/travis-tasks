module Travis
  module Backends
    class Base
      def name
        raise NotImplementedError
      end

      def create_check_run(id:, type:, payload:)
        raise NotImplementedError
      end

      def update_check_run(id:, type:, check_run_id:, payload:)
        raise NotImplementedError
      end

      def check_runs(id:, type:, ref:, check_run_name:)
        raise NotImplementedError
      end

      def create_status(id:, type:, ref:, payload:)
        raise NotImplementedError
      end

      def file_url(id:, type:, slug:, branch:, file:)
        raise NotImplementedError
      end

      def branch_url(id:, type:, slug:, branch:)
        raise NotImplementedError
      end

      def create_check_run_url(id)
        raise NotImplementedError
      end

      def create_status_url(id, ref)
        raise NotImplementedError
      end
    end
  end
end
