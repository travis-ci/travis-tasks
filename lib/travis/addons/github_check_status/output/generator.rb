module Travis::Addons::GithubCheckStatus::Output
  class Generator
    FIELDS             = %i[ name head_sha details_url external_id status conclusion started_at completed_at ]
    OUTPUT_FIELDS      = %i[ title summary text annotations images ]
    include Helpers
    attr_reader :payload, :build_info

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

    def branch
      build_info.head_ref
    end

    def head_sha
      build_info.sha
    end

    def external_id
      payload[:build][:id].to_s
    end

    def details_url
      "#{Travis.config.http_host}/#{Travis::Addons::Util::Helpers.vcs_prefix(repository[:vcs_type])}/#{slug}/builds/#{external_id}"
    end

    def title
      "Build #{state.capitalize}"
    end

    def summary
      template(:summary, summary_type)
    end

    def summary_type
      case state
      when 'queued'       then :queued
      when 'started'      then :running
      when previous_state then :unchanged
      else previous_state.present? ? :changed : :no_previous
      end
    end

    def text
      template(:text).strip
    end

    def annotations
    end

    def images
    end

    def started_at
      build[:started_at]
    end

    def completed_at
      finished_at if completed?
    end

    def language_info
      content = ""
      LANGUAGES.each do |key, description|
        next unless values = Array(build[:config][key]) and values.any?
        content << "#{description} Version#{'s' if values.size > 1}".ljust(16) << " | " << values.map { |v| escape(v) }.join(', ') << "\n"
      end
      content.strip
    end

    def config_display_text
      payload[:config_display_text] || yaml(build[:config])
    end

    def job_info_text
      payload[:job_info_text] || @job_info.description
    end

    def yaml(config)
      # config.deep_stringify_keys.to_yaml.sub(/^---\n/, '')
      JSON.pretty_generate(config)
    end

    def to_h(*fields)
      output = OUTPUT_FIELDS.map { |k| [k, public_send(k)] }.select(&:last).to_h
      fields = FIELDS       .map { |k| [k, public_send(k)] }.select(&:last).to_h
      fields.merge(output: output)
    end
  end
end
