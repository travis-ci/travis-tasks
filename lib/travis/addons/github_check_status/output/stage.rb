module Travis::Addons::GithubCheckStatus::Output
  class Stage
    include Helpers
    attr_reader :stage, :jobs, :headers

    def initialize(generator, stage, jobs)
      super(generator)
      @headers = ['Job', *MATRIX_KEYS.values, 'State', 'Notes']
      @stage   = stage
      @jobs    = jobs
    end

    def description
      description = ''
      description << template(:stage_description) << "\n" if stage
      description << table
      description
    end

    def table
      template(:jobs_table)
    end

    def format_row(row, element = 'td')
      html = row.each_with_index.map { |cell, index| "    <#{element}>#{cell}</#{element}>" unless skip_cell?(index) }.compact.join("\n")
      "  <tr>\n#{html}\n  </tr>"
    end

    def skip_cell?(index)
      table_data.all? { |row| !row[index].present? }
    end

    def job_url(job)
      "#{Travis.config.http_host}/#{slug}/jobs/#{job[:id]}"
    end

    def table_body
      table_data.map { |row| format_row(row) }.join("\n")
    end

    def table_head
      format_row(headers, 'th')
    end

    def matrix_attributes(job)
      MATRIX_KEYS.each_key.map do |key|
        matrix_value(key, job[:config][key], job) if job[:config][key] != build[:config][key]
      end
    end

    def matrix_value(key, value, job)
      return unless value.present?
      case key
      when :os      then os_description(job, value)
      when :gemfile then "<a href='#{file_link(value)}'>#{escape(value)}</a>"
      else escape(value)
      end
    end

    def notes(job)
      template(:allow_failure) if job[:allow_failure]
    end

    def job_name(job)
      return job[:name] unless job[:name].nil?
      job[:number]
    end
    
    def table_data
      @table_data ||= jobs.map do |job|
        [
          build_link(job[:state], job_url(job), job_name(job)),
          *matrix_attributes(job),
          state(job[:state]),
          notes(job)
        ]
      end
    end

  end
end
