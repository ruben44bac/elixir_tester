## STAGE 1: Build ##
#docker build -t guiltySpark_umbrella:x.y.z exit


FROM elixir:1.9.1 as builder

ENV MIX_ENV=prod

RUN apt install curl \
  && curl -sL https://deb.nodesource.com/setup_12.x | bash - \
  && apt-get install -y nodejs \
  && apt-get install -y npm

RUN mix local.hex --force \
  && mix local.rebar --force

ADD . .

RUN mix deps.get --only prod \
  && cd apps/guiltySpark_web/assets \
  && npm install \
  && npm run deploy --prefix \
  && cd .. \
  && cd .. \
  && cd ..\
  && mix phx.digest \
  && mix distillery.release --name=guiltySpark_umbrella --env=$MIX_ENV

## STAGE 2: Release ##

FROM elixir:1.9.1-slim

MAINTAINER Ruben Baeza (ruben.baeza@santiago.mx)

EXPOSE ${PORT}

COPY --from=builder /_build /_build

CMD ["_build/prod/rel/guiltySpark_umbrella/bin/guiltySpark_umbrella", "foreground"]