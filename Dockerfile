FROM ruby:latest

RUN curl -sLO 'https://download.oracle.com/otn_software/linux/instantclient/19600/instantclient-basic-linux.x64-19.6.0.0.0dbru.zip' && \
  curl -sLO 'https://download.oracle.com/otn_software/linux/instantclient/19600/instantclient-sdk-linux.x64-19.6.0.0.0dbru.zip' && \
  unzip instantclient-basic-linux.x64-19.6.0.0.0dbru.zip && \
  unzip instantclient-sdk-linux.x64-19.6.0.0.0dbru.zip && \
  rm instantclient-basic-linux.x64-19.6.0.0.0dbru.zip && \
  rm instantclient-sdk-linux.x64-19.6.0.0.0dbru.zip

RUN apt update && \
  apt-get install libaio1

ENV LD_LIBRARY_PATH /instantclient_19_6:$LD_LIBRARY_PATH

RUN mkdir /app
WORKDIR /app
COPY . /app
RUN bundle install
