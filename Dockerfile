FROM ruby:2.6.6-slim

LABEL maintainer Travis CI GmbH <support+travis-tasks-docker-images@travis-ci.com>

# packages required for bundle install
RUN ( \
   apt-get update ; \
   apt-get install -y --no-install-recommends git make gcc curl \
   && rm -rf /var/lib/apt/lists/* \
)

RUN ( \
   curl -sLO http://ppa.launchpad.net/rmescandon/yq/ubuntu/pool/main/y/yq/yq_3.1-2_amd64.deb && \
   dpkg -i yq_3.1-2_amd64.deb && \
   rm -f yq_3.1-2_amd64.deb; \
)

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /app
WORKDIR /app

COPY Gemfile      /app
COPY Gemfile.lock /app

RUN bundle install --deployment

COPY . /app
