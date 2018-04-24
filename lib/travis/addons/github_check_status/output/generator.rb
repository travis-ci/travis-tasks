module Travis::Addons::GithubCheckStatus::Output
  class Generator
    FIELDS        = %i[ name branch sha details_url external_id status conclusion completed_at ]
    OUTPUT_FIELDS = %i[ title summary text annotations images ]

    include Helpers
    attr_reader :payload, :build_info, :job_info

    def initialize(payload)
      @payload    = payload
      @build_info = pull_request? ? PullRequest.new(self) : Push.new(self)
      @job_info   = matrix?       ? Matrix.new(self)      : SingleJob.new(self)
    end

    def generator
      self
    end

    def name
      template(:name)
    end

    def sha
      build_info.sha
    end

    def details_url
      "#{Travis.config.http_host}/#{slug}/builds/#{external_id}"
    end

    def title
      "Build #{state.capitalize}"
    end

    def summary
      template(:summary, state == previous_state ? :unchanged : :changed)
    end

    def text
      template(:text).strip
    end

    def annotations
    end

    def images
    end

    def completed_at
      finished_at if completed?
    end

    def to_h(*fields)
      output = OUTPUT_FIELDS.map { |k| [k, public_send(k)] }.select(&:last).to_h
      fields = FIELDS       .map { |k| [k, public_send(k)] }.select(&:last).to_h
      fields.merge(output: output)
    end
  end
end
