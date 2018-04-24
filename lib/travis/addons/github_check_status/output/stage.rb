module Travis::Addons::GithubCheckStatus::Output
  class Stage
    HEADERS = ['Job', 'State', 'Notes']

    include Helpers
    attr_reader :stage, :jobs

    def initialize(generator, stage, jobs)
      super(generator)
      @stage = stage
      @jobs  = jobs
    end

    def description
      description = ''
      description << template(:stage_description) << "\n" if stage
      description << table
      description
    end

    def table
      [
        format_row(HEADERS),
        table_separator,
        *table_data.map { |row| format_row(row) }
      ].join("\n")
    end

    def format_row(row)
      row.each_with_index.map { |cell, index| " #{cell.to_s.ljust(cell_width(index))} " unless skip_cell?(index) }.compact.join('|').rstrip
    end

    def table_separator
      HEADERS.size.times.map { |i| '-' * (cell_width(i)+2) unless skip_cell?(i) }.compact.join('|')
    end

    def cell_width(index)
      [HEADERS[index].size, *table_data.map { |r| r[index].size }].max
    end

    def skip_cell?(index)
      table_data.all? { |row| !row[index].present? }
    end

    def job_url(job)
      "#{Travis.config.http_host}/#{slug}/jobs/#{job[:id]}"
    end

    def table_data
      @table_data ||= jobs.map do |job|
        [
          "![](#{icon_url(job[:state])}) [#{job[:number]}](#{job_url(job)})",
          state(job[:state])
        ]
      end
    end
  end
end
