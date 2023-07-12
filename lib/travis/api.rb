require 'travis/backends/base'
require 'travis/backends/github'
require 'travis/backends/vcs'

module Travis
  module Api
    extend self

    def backend(vcs_id, vcs_type, installation_id: nil)
      puts "##############################"
      puts "##############################"
      puts "##############################"
      puts "##############################"
      puts "Travis::Api::backend"
      puts "vcs_id IS: #{vcs_id}"
      puts "vcs_type IS: #{vcs_type}"
      puts "installation_id IS: #{installation_id}"
      if Travis::Rollout.matches?(:vcs, id: vcs_id) || !vcs_type.match(/Github/)
        puts "##############################"
        puts "Travis::Api::backend.if"
        puts "Backend is: #{Travis::Backends::Vcs.new}"
        Travis::Backends::Vcs.new
      else
        puts "##############################"
        puts "Travis::Api::backend.else"
        puts "Backend is: #{Travis::Backends::Github.new(installation_id)}"
        Travis::Backends::Github.new(installation_id)
      end
    end

  end
end
