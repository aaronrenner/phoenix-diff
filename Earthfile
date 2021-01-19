build:
  FROM earthly/earthly:v0.4.5
  RUN apk add --no-progress --update wget elixir

  RUN mix local.hex --force
  RUN mix local.rebar --force

  WORKDIR /src

  COPY mix.exs mix.lock .

  RUN mix deps.get

  COPY --dir config/ .

  RUN MIX_ENV=test mix deps.compile

  COPY --dir data/ lib/ priv/ test/ .

  WITH DOCKER
    RUN --privileged PHX_DIFF_EARTHLY_PATH=earthly-buildkitd-wrapper.sh mix test
  END
