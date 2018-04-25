module Travis::Addons::GithubCheckStatus::Output
  TEMPLATES = {
    name: 'Travis CI − {{build_info.name}}',

    summary: {
      queued:      '{{icon}} The build is currently waiting in the build queue for a VM to be ready.',
      running:     '{{icon}} The build is currently running.',
      changed:     '{{icon}} The build **{{state}}**. This is a change from the previous build, which **{{previous_state}}**.',
      unchanged:   '{{icon}} The build **{{state}}**, just like the previous build.',
      no_previous: '{{icon}} The build **{{state}}**.'
    },

    matrix_description: {
      without_stages: 'This build has **{{number jobs.size}} jobs**, running in parallel.',
      with_stages:    'This build has **{{number jobs.size}} jobs**, running in **{{number stages.size}} sequential stages**.'
    },

    allow_failure: "This job is <a href='https://docs.travis-ci.com/user/customizing-the-build#Rows-that-are-Allowed-to-Fail'>allowed to fail</a>.",

    stage_description: <<-MARKDOWN,
      ### Stage {{stage[:number]}}: {{escape stage[:name]}}
      This stage **{{state stage[:state]}}**.
    MARKDOWN

    text: <<-MARKDOWN,
      {{build_info.description}}

      ## Jobs and Stages
      {{job_info.description}}

      ## Build Configuration

      Build Option     | Setting
      -----------------|--------------
      Language         | {{language}}
      Operating System | {{os_description}}
      Sudo Access      | {{build[:config][:sudo] ? 'required' : 'not required'}}
      {{language_info}}

      {{build_script_info}}

      <details>
      <summary>Build Configuration</summary>
      {{code :yaml, yaml(build[:config])}}
      </details>
    MARKDOWN

    jobs_table: <<-HTML,
      <table>
        <thead>
          {{ table_head.rstrip }}
        </thead>
        <tbody>
          {{ table_body.rstrip }}
        </tbody>
      </table>
    HTML
  }
end
