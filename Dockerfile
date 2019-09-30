FROM ruby:2.5.3

LABEL maintainer Travis CI GmbH <support+travis-tasks-docker-images@travis-ci.com>

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /app
WORKDIR /app

COPY Gemfile      /app
COPY Gemfile.lock /app

RUN bundle install --deployment

COPY . /app

CMD /bin/bash