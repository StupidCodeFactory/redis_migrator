FROM ruby:2.6.3-alpine

WORKDIR /app

RUN apk update && apk add git build-base

RUN gem install bundler:2.0.1

COPY . /app/

RUN bundle

ENTRYPOINT ["bundle", "exec"]

CMD ["rspec"]
