BRUNCH = node_modules/brunch/bin/brunch
ELM_PACKAGE = ../../node_modules/elm/binwrappers/elm-package
ELM_TEST = ../../node_modules/elm-test/bin/elm-test
ELM_TEST_COMPILER = ../../../node_modules/elm/binwrappers/elm-make
FLOW = node_modules/.bin/flow

.PHONY: static-build install server iex-server container flow test clean elm elm-watch elm-test dl-maxmind do-install

install: do-install

do-install:
	mix deps.get \
	&& cd apps/sre \
	&& npm install \
	&& cd web/elm \
	&& $(ELM_PACKAGE) install -y \
	&& cd tests \
	&& ../$(ELM_PACKAGE) install -y

server:
	MIX_ENV=dev mix phoenix.server

iex-server:
	MIX_ENV=dev iex -S mix phoenix.server

mix:
	MIX_ENV=dev iex -S mix

static-build:
	cd apps/sre/ && $(BRUNCH) build

lint:
	npm run lint

flow:
	npm run flow

test:
	MIX_ENV=test mix test

clean:
	rm -rf apps/sre/node_modules \
	&& rm -rf apps/sre/web/elm/elm-stuff \
	&& rm -rf _build \
	&& rm -rf deps \
	&& rm *.mmdb

npm-install:
	cd ./apps/sre && npm install && cd ../../

elm-install:
	cd apps/sre/web/elm \
	&& $(ELM_PACKAGE) install -y \
	&& cd ../../../../

elm:
	cd apps/sre/ && node scripts/elm-make.js

elm-debug:
	cd apps/sre/ && node scripts/elm-make-debug.js

elm-watch:
	cd apps/sre/ && node scripts/elm-watch.js

elm-test:
	cd apps/sre/web/elm \
	&& if [ -f $(ELM_TEST) ]; then $(ELM_TEST) --compiler $(ELM_TEST_COMPILER); else elm-test --compiler $(ELM_TEST_COMPILER); fi # Use global if local missing

dl-maxmind:
	if [ -z "${MAXMIND_EDITIONS}" ] || [ -z "${MAXMIND_KEY}" ]; then echo "\n\nError: Please define MAXMIND_EDITIONS and MAXMIND_KEY in .env"; \
	else \
	curl -o maxmind.tar.gz -L "https://download.maxmind.com/app/geoip_download?edition_id=${MAXMIND_EDITIONS}&suffix=tar.gz&license_key=${MAXMIND_KEY}" \
	&& tar -zxvf maxmind.tar.gz -C . --strip-components=1 "*/${MAXMIND_EDITIONS}.mmdb" \
	&& rm maxmind.tar.gz; \
	fi
