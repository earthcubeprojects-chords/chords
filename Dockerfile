FROM ruby:2.7-slim

# Install apt based dependencies required to run Rails as
# well as RubyGems. As the Ruby image itself is based on a
# Debian image, we use apt-get to install those.
RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential \
  nodejs \
  default-mysql-client \
  default-libmysqlclient-dev \
  dos2unix \
  cron \
  git \
  apt-utils \
  curl \
  nano \
  && rm -rf /var/lib/apt/lists/*

# Configure the main working directory. This is the base
# directory used in any further RUN, COPY, and ENTRYPOINT
# commands.
RUN mkdir -p /chords
WORKDIR /chords

# Copy the Gemfile as well as the Gemfile.lock and install
# the RubyGems. This is a separate step so the dependencies
# will be cached unless changes to one of those two files
# are made.
COPY Gemfile Gemfile.lock ./
#
# setting BUNDLE_JOBS to more than 1 will cause bundle install's console
# output to show up asynchronously, potentially making debugging more difficult
#
ENV BUNDLE_JOBS 1
RUN gem install bundler -v '2.4.22' && bundle install --jobs $BUNDLE_JOBS --retry 5

# Copy the main application.
COPY . ./

# Bake the assets (for production mode) into the image
RUN mkdir -p /chords/log && RAILS_ENV=production SECRET_KEY_BASE=`bundle exec rake secret` bundle exec rake assets:precompile

# Create the CHORDS environment value setting script chords_env.sh.
# Use this bit of magic to invalidate the Dokcker cache to ensure that the command is run.
ADD https://www.random.org/integers/\?num\=1\&min\=1\&max\=1000000000\&col\=1\&base\=10\&format\=plain\&rnd\=new cache_invalidator
RUN /bin/bash -f create_chords_env_script.sh > chords_env.sh && chmod a+x chords_env.sh

# Install Docker on the container itself
RUN curl -sSL https://get.docker.com/ | DEBIAN_FRONTEND=noninteractive sh

# Remove artifacts that are not needed. The docker image will only shrink
# however if the docker build command is run with the --squash option
RUN rm -rf .git log/* tmp/*

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Expose port 3000 to the Docker host, so we can access it
# from the outside.
EXPOSE 3042

# Configure an entry point, so we don't need to specify
# "bundle exec" for each of our commands.
ENTRYPOINT ["bundle", "exec"]

# Start CHORDS
CMD ["cron", "&&", "/bin/bash", "-f", "chords_start.sh"]
