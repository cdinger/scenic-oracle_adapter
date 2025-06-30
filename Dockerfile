FROM ghcr.io/cdinger/oracle-ruby:3.4

RUN mkdir /app
WORKDIR /app
COPY . /app
RUN bundle install
