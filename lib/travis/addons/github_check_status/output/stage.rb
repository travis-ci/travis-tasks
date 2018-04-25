module Travis::Addons::GithubCheckStatus::Output
  class Stage
    include Helpers
    attr_reader :stage, :jobs, :headers

    def initialize(generator, stage, jobs)
      super(generator)
      @headers = ['Job', 'State', 'Notes']
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

    def table_data
      @table_data ||= jobs.map do |job|
        [
          "#{icon(job[:state])} <a href='#{job_url(job)}'>#{job[:number]}</a>",
          state(job[:state])
        ]
      end
    end
  end
end
