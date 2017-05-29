FROM ruby:2.3.1
MAINTAINER admin@buzzn.net

# Set Rails to run in production
ENV RAILS_ENV production
ENV RACK_ENV production
ENV DB_ADAPTER nulldb
ENV SECRET_KEY_BASE 4302a93016c91a2074f05c247570bd12a604c3368d711861df1cbab4b967d81796562097aad566f12016a721a6f461a1cd376a94f826721ab6fb8b483c5b8b81

# Install apt based dependencies required to run Rails as
# well as RubyGems. As the Ruby image itself is based on a
# Debian image, we use apt-get to install those.
RUN apt-get update && \
  apt-get install -y \
  build-essential \
  imagemagick \
  cron \
  nodejs

# Configure the main working directory. This is the base
# directory used in any further RUN, COPY, and ENTRYPOINT
# commands.
RUN mkdir -p /core
WORKDIR /core

# Copy the Gemfile as well as the Gemfile.lock and install
# the RubyGems. This is a separate step so the dependencies
# will be cached unless changes to one of those two files
# are made.
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 20 --retry 5 --without development test


# Copy the main application.
COPY . ./

# Precompile Rails assets
# http://blog.zeit.io/use-a-fake-db-adapter-to-play-nice-with-rails-assets-precompilation/
RUN bundle exec rake assets:precompile -t


# Expose port 3000 to the Docker host, so we can access it
# from the outside.
EXPOSE 3000

# The main command to run when the container starts. Also
# tell the Rails dev server to bind to all interfaces by
# default.
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
