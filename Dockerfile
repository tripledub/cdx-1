FROM finddx/cdx-nginx-rails:latest

## Create a user for the web app.
# RUN \
#   addgroup --gid 9999 app && \
#   adduser --uid 9999 --gid 9999 --disabled-password --gecos "Application" app && \
#   usermod -L app

ENV PUMA_OPTIONS "--preload -w 4"
ENV RAILS_ENV production

# Install gem bundle
WORKDIR /app
COPY ["Gemfile", "Gemfile.lock", "/app/"]
RUN bundle install --without development test --jobs 4
ADD . /app
RUN bundle install --jobs 8 --deployment --without development test

RUN bundle exec rake tmp:create

# Precompile assets
RUN bundle exec rake assets:precompile RAILS_ENV=production

# Add config files
# ADD docker/web-run /etc/service/web/run
# ADD docker/client_max_body_size.conf /etc/nginx/conf.d/client_max_body_size.conf
