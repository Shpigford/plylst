FROM ruby:2.7.2

WORKDIR /usr/src/app

RUN apt-get update
RUN apt-get install nodejs -y

RUN gem install bundler foreman

COPY Gemfile Gemfile.lock /usr/src/app/

RUN bundle install

COPY . /usr/src/app/

ENTRYPOINT ["/usr/src/app/entrypoint.sh"]
