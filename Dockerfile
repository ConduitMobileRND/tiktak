FROM elixir:1.6.5-alpine

WORKDIR /home/app

RUN apk update && apk upgrade && apk add bash
RUN wget https://s3.amazonaws.com/rebar3/rebar3 && chmod +x rebar3 && mix local.rebar

ADD . /tmp/build
RUN cd /tmp/build \
    && yes | mix deps.get \
    && MIX_ENV=prod mix release \
    && mv -v _build/prod/* /home/app/ \
    && rm -fr /tmp/build

ENV REPLACE_OS_VARS true
CMD /home/app/rel/tiktak/bin/tiktak migrate && /home/app/rel/tiktak/bin/tiktak foreground