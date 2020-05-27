FROM elixir:1.10.2

ENV MIX_ENV=prod

RUN apt-get update \
	&& apt-get install -y --no-install-recommends postgresql-client \
	xvfb libfontconfig wkhtmltopdf gettext-base \
	&& apt-get clean  && rm -rf /var/lib/apt/lists

RUN mkdir /app
COPY . /app
WORKDIR /app

# install elixir project dependencies
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get

# build
RUN mix compile

CMD ["/bin/bash", "-c", "/app/entrypoint.sh"]
