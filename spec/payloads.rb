TASK_PAYLOAD = {
  "repository" => {
    "id"=>1,
    "key"=>"-----BEGIN PUBLIC KEY-----",
    "slug"=>"svenfuchs/minimal",
    "name"=>"minimal",
    "owner_email"=>"svenfuchs@artweb-design.de",
    "owner_avatar_url"=>nil
  },
  "request" => {
    "token"=>"token",
    "head_commit"=>"head-commit"
  },
  "commit" => {
    "id"=>1,
    "sha"=>"62aae5f70ceee39123ef",
    "branch"=>"master",
    "message"=>"the commit message",
    "committed _at"=>"2014-04-03T09:22:05Z",
    "author_name"=>"Sven Fuchs",
    "author_email"=>"svenfuchs@artweb-design.de",
    "committer_name"=>"Sven Fuchs",
    "committer_email"=>"svenfuchs@artweb-design.de",
    "compare_url"=>"https://github.com/svenfuchs/minimal/compare/master...develop"
  },
  "build" => {
    "id"=>1,
    "repository_id"=>1,
    "commit_id"=>1,
    "number"=>2,
    "pull_request"=>false,
    "config" => {
      "rvm"=>["1.8.7", "1.9.2"],
      "gemfile"=>["test/Gemfile.rails-2.3.x", "test/Gemfile.rails-3.0.x"]
    },
    "state"=>"passed",
    "previous_state"=>"passed",
    "started_at"=>"2014-04-03T10:21:05Z",
    "finished_at"=>"2014-04-03T10:22:05Z",
    "duration"=>60,
    "job_ids"=>[1, 2]
  },
  "jobs"=>[{
    "id"=>1,
    "number"=>"2.1",
    "state"=>"passed"
  }, {
    "id"=> 2,
    "number"=>"2.2",
    "state"=>"passed",
  }]
}

WEBHOOK_PAYLOAD = {
  "id"=>1,
  "repository"=>{
    "id"=>1,
    "name"=>"minimal",
    "owner_name"=>"svenfuchs",
    "url"=>"http://github.com/svenfuchs/minimal"
  },
  "number"=>2,
  "config"=> {
    "rvm"=>["1.8.7", "1.9.2"],
    "gemfile"=>["test/Gemfile.rails-2.3.x", "test/Gemfile.rails-3.0.x"]
  },
  "status"=>0,
  "result"=>0,
  "status_message"=>"Passed",
  "result_message"=>"Passed",
  "started_at"=>"2014-04-03T13:50:39Z",
  "finished_at"=>"2014-04-03T13:51:39Z",
  "duration"=>60,
  "build_url"=>"https://travis-ci.org/svenfuchs/minimal/builds/1",
  "commit"=>"62aae5f70ceee39123ef",
  "branch"=>"master",
  "message"=>"the commit message",
  "compare_url"=>"https://github.com/svenfuchs/minimal/compare/master...develop",
  "committed_at"=>"2014-04-03T12:51:39Z",
  "author_name"=>"Sven Fuchs",
  "author_email"=>"svenfuchs@artweb-design.de",
  "committer_name"=>"Sven Fuchs",
  "committer_email"=>"svenfuchs@artweb-design.de",
  "matrix" => [{
    "id"=>1,
    "repository_id"=>1,
    "parent_id"=>1,
    "number"=>"2.1",
    "state"=>"finished",
    "config"=>{"rvm"=>"1.8.7", "gemfile"=>"test/Gemfile.rails-2.3.x"},
    "status"=>0,
    "result"=>0,
    "commit"=>"62aae5f70ceee39123ef",
    "branch"=>"master",
    "message"=>"the commit message",
    "compare_url"=>"https://github.com/svenfuchs/minimal/compare/master...develop",
    "committed_at"=>"2014-04-03T12:51:39Z",
    "author_name"=>"Sven Fuchs",
    "author_email"=>"svenfuchs@artweb-design.de",
    "committer_name"=>"Sven Fuchs",
    "committer_email"=>"svenfuchs@artweb-design.de",
    "started_at"=>"2014-04-03T13:50:39Z",
    "finished_at"=>"2014-04-03T13:51:39Z"
  }, {
    "id"=>2,
    "repository_id"=>1,
    "parent_id"=>1,
    "number"=>"2.2",
    "state"=>"finished",
    "config"=>{"rvm"=>"1.8.7", "gemfile"=>"test/Gemfile.rails-2.3.x"},
    "status"=>0,
    "result"=>0,
    "commit"=>"62aae5f70ceee39123ef",
    "branch"=>"master",
    "message"=>"the commit message",
    "compare_url"=>"https://github.com/svenfuchs/minimal/compare/master...develop",
    "committed_at"=>"2014-04-03T12:51:39Z",
    "author_name"=>"Sven Fuchs",
    "author_email"=>"svenfuchs@artweb-design.de",
    "committer_name"=>"Sven Fuchs",
    "committer_email"=>"svenfuchs@artweb-design.de",
    "started_at"=>"2014-04-03T13:50:39Z",
    "finished_at"=>"2014-04-03T13:51:39Z"
  }],
  "type"=>"push"
}
