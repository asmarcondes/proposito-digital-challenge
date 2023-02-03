FROM ruby:3.1.2

WORKDIR /app
COPY . /app

RUN bundle install

EXPOSE 4567

ENTRYPOINT ["sh", "docker-entrypoint.sh"]