# == base
FROM ruby:3.2.3-alpine AS base

WORKDIR /app

ENV APP_DOMAIN=localhost.scvl.jp \
  RAILS_ENV=production \
  BUNDLE_DEPLOYMENT=true \
  BUNDLE_PATH=vendor/bundle \
  BUNDLE_WITHOUT=development:test

# build-base and gcompat are necessary for tailwindcss-rails to work properly
RUN gem install bundler --no-document --version 2.5.5 && \
  apk update && apk add --no-cache --update \
  build-base \
  bash \
  gcompat

FROM base AS builder

# Add packages
RUN apk update && apk add --no-cache --update \
  postgresql-dev \
  tzdata \
  git \
  shared-mime-info

# == bundle
FROM builder AS bundle

# Install gems
COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install --jobs 4 \
  && rm -rf $BUNDLE_PATH/ruby/$RUBY_VERSION/cache/*

# == assets
FROM builder AS assets

COPY . .

COPY --from=bundle /app/vendor/bundle /app/vendor/bundle

# Set a dummy value to avoid errors when building docker image.
# refs: https://github.com/rails/rails/issues/32947
RUN SECRET_KEY_BASE=dummy bundle exec rails assets:precompile && \
  rm -rf tmp/cache/*

# == main
FROM base AS main

# Add packages
RUN apk update && apk add --no-cache --update \
  postgresql-dev \
  tzdata \
  shared-mime-info \
  make \
  gcc \
  g++

COPY . .

# Copy files from each stages
COPY --from=bundle /app/vendor/bundle /app/vendor/bundle
COPY --from=assets /app/public/assets public/assets

ARG SHA
ENV SHA ${SHA}
ENV PORT 3000
EXPOSE ${PORT}

CMD ["bin/rails", "server", "-b", "0.0.0.0"]