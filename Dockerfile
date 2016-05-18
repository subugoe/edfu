FROM rails:latest

RUN apt-get update && apt-get install -y netcat

RUN mkdir /edfu
WORKDIR /edfu

ADD Gemfile /edfu/Gemfile
ADD Gemfile.lock /edfu/Gemfile.lock

RUN bundle install

ADD . /edfu

#EXPOSE 3000
