module Travis::Addons::GithubCheckStatus::Output
  module Helpers
    STATUS = {
      'created'  => 'queued',
      'queued'   => 'queued',
      'started'  => 'in_progress',
      'passed'   => 'completed',
      'failed'   => 'completed',
      'errored'  => 'completed',
      'canceled' => 'completed',
    }

    CONCLUSION = {
      'passed'   => 'success',
      'failed'   => 'failure',
      'errored'  => 'action_required',
      'canceled' => 'neutral',
    }

    ICON = {
      'created'  => 'icon-running.png',
      'queued'   => 'icon-running.png',
      'started'  => 'icon-running.png',
      'passed'   => 'icon-passed.png',
      'failed'   => 'icon-failed.png',
      'errored'  => 'icon-errored.png',
      'canceled' => 'icon-canceled.png',
    }

    NUMBERS = %w[zero one two three four five six seven eight nine ten]

    def self.hash_accessors(method, *fields)
      fields.each do |field|
        field = { field => field } unless field.is_a? Hash
        field.each { |k,v| module_eval "def #{k}; #{method}[:#{v}]; end" }
      end
    end

    hash_accessors :payload, :build, :jobs, :owner, :repository, :request, :pull_request, :tag, :commit
    hash_accessors :repository, :slug
    hash_accessors :commit, :branch, :author_name, :committer_name
    hash_accessors :build, :state, :previous_state, :finished_at, pull_request?: :pull_request, external_id: :id

    attr_reader :generator

    def initialize(generator)
      @generator = generator
    end

    def icon_url(state = self.state)
      "#{Travis.config.http_host}/images/stroke-icons/#{ICON.fetch(state)}"
    end

    def payload
      generator.payload
    end

    def matrix?
      jobs.size > 1
    end

    def completed?
      status == 'completed'
    end

    def status
      @status ||= STATUS.fetch(state)
    end

    def conclusion
      CONCLUSION[state]
    end

    def template(*keys)
      @templates       ||= {}
      @templates[keys] ||= keys.inject(TEMPLATES) { |t,k| t.fetch(k) }.gsub(/^ +/, '').gsub(/\{\{([^\}]+)\}\}/) { eval($1) }
    end

    def number(input)
      NUMBERS.fetch(input, input)
    end
  end
end
