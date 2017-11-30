### Elm Development

Root directory for Elm is `apps/sre/web/elm/`.

#### Adding Ports

To add a new general-use port module to be reused across Elm apps:

1. Create an Elm port module in `elm/lib/Ports/`. (Don't forget the `port module` syntax at the beginning of the file.)
1. Create a matching JavaScript port module in `apps/sre/web/static/js/ports/`, exporting a `register` function and a `samplePortName` String. (See others for examples.)
1. Add the JavaScript file to the registry in `apps/sre/web/static/js/ports.js`.

#### Watching

After running `make iex-server`, run `make elm-watch` to watch for changes to Elm files.

#### Testing Elm code

##### Run tests

```
make elm-test
```

##### Add new tests

1. Add a test file under `apps/sre/web/elm/tests` in the analogous directory of your Elm module. Namespace it under `Test`. (E.g. for `elm/lib/Device.elm` make a test file at `elm/tests/lib/Test/Device.elm`)
1. Add the module to the test registry in `apps/sre/web/elm/tests/Tests.elm` in the `all` function.
1. Run `make elm-test` from the repository root to ensure the new tests run.
