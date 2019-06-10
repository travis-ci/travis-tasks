FROM ruby:2.4.2

LABEL maintainer Travis CI GmbH <support+travis-app-docker-images@travis-ci.com>

# required for envsubst tool
RUN ( \
   apt-get update ; \
   apt-get install -y --no-install-recommends  gettext-base; \
   rm -rf /var/lib/apt/lists/* \
)

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile      /usr/src/app
COPY Gemfile.lock /usr/src/app

RUN bundle install

COPY . /usr/src/app

CMD bundle exec je sidekiq -c 25 -r ./lib/travis/tasks.rb -q notifications -q campfire -q email -q flowdock -q github_commit_status -q github_status -q hipchat -q irc -q webhook -q slack -q pushover
