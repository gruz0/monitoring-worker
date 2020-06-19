FROM ruby:2.7.1-alpine
MAINTAINER Alexander Kadyrov <gruz0.mail@gmail.com>

ENV BUNDLER_VERSION='2.1.4'

# Create an user for running the application
RUN adduser -D user
USER user
WORKDIR /home/user

COPY --chown=user Gemfile Gemfile.lock ./
RUN gem install bundler --no-document
RUN bundle install --jobs $(nproc) --retry 5

COPY --chown=user . ./

CMD ./docker-entrypoint.sh
