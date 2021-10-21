require 'travis/backends/base'
require 'travis/backends/vcs'

module Travis
  module Api
    extend self

    def backend(vcs_id, vcs_type, installation_id: nil)
      Travis::Backends::Vcs.new
    end
  end
end
