# == base
# NOTE: alipne3.14 causes some problems on certain versions of 
# Docker or Fargate
# https://github.com/docker-library/ruby/issues/351
FROM ruby:3.0.2-alpine3.13 AS base

WORKDIR /app
ENV RAILS_ENV production
ENV NODE_ENV production
ENV BUNDLE_DEPLOYMENT true
ENV BUNDLE_PATH vendor/bundle
ENV BUNDLE_WITHOUT development:test

RUN gem install bundler --no-document --version 2.3.5 && \
  apk update && apk add --no-cache --update \
  build-base \
  linux-headers

FROM base AS builder

# Add packages
RUN apk update && apk add --no-cache --update \
  postgresql-dev \
  tzdata \
  git \
  yarn \
  shared-mime-info

# == bundle
FROM builder AS bundle

# Install gems
COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install --jobs 4 \
      && rm -rf $BUNDLE_PATH/ruby/$RUBY_VERSION/cache/*

# == yarn
FROM builder AS yarn

# Install yarn packages
COPY package.json .
COPY yarn.lock .
RUN if [ "$NODE_ENV" = "production" ]; \
    then yarn install --production --frozen-lockfile && yarn cache clean; \
    else yarn install --frozen-lockfile && yarn cache clean; \
    fi 

# == assets
FROM builder AS assets

COPY . .

COPY --from=bundle /app/vendor/bundle /app/vendor/bundle
COPY --from=yarn /app/node_modules node_modules

# Set a dummy value to avoid errors when building docker image.
# refs: https://github.com/rails/rails/issues/32947
RUN SECRET_KEY_BASE=dummy bundle exec rails assets:precompile
RUN rm -rf tmp/cache/*

# == main
FROM base AS main

# Add packages
RUN apk update && apk add --no-cache --update \
      postgresql-dev \
      tzdata \
      nodejs \
      shared-mime-info \
      make \
      gcc \
      g++ \
      yarn

COPY . .

# Copy files from each stages
COPY --from=bundle /app/vendor/bundle /app/vendor/bundle
COPY --from=assets /app/public/assets public/assets
COPY --from=assets /app/public/packs public/packs

ARG SHA
ENV SHA ${SHA}
ENV PORT 3000
EXPOSE ${PORT}

CMD ["bin/rails", "server", "-b", "0.0.0.0"]