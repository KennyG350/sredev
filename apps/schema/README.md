# Schema

Adds a place to manage resources for the schema DB project.

*This application should never be a dependency in side of the sre phoneix server*


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `schema` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:schema, "~> 0.1.0"}]
    end
    ```

  2. Ensure `schema` is started before your application:

    ```elixir
    def application do
      [applications: [:schema]]
    end
    ```
