## SRE.com

SRE.com is a real estate listing portal.

### Phoenix / Elixir Resources and Shortcuts

1. [Plug Middlewares](https://hexdocs.pm/plug/readme.html)
2. `iex <filename>` will execute a file
3. Routes can travel through pipelines or middlewares before resolving the route handlers via the controllers
4. [Macros](http://www.phoenixframework.org/docs/routing)
5. See process tree: `iex -S mix phoenix.server` -> :observer.start
6. To see routes via command line `cd apps/sre && mix phoenix.routes`
7. [Package Manager](hexdocs.pm)
8. [Connection](https://hexdocs.pm/plug/Plug.Conn.html)
9. [Credo](https://github.com/rrrene/credo)
10. In iex - `h <function>` provides information about the function

### [Elm Development](./apps/sre/web/elm/README.md)

### Alias vs Require vs Import

Alias - Typing a shorter name (Sre.Web.render -> Sre.render)
  - Guideline: Should alias anything that is nested more than 2 modules deep
Require - Process macros before loading module
Import - Doesn't process the files, but loads them

### Deploys

1. Merge develop into master
1. Bump version in mix.exs (/apps/sre/mix.exs)
1. Commit version change on master
1. Tag needs to match version number (example: `1.1.1`, don't prefix with v)
1. In Gitlab, go to sre.com -> Tags -> Click on actions, then Deploy

1. If a migration runs, restart application via heroku toolbelt `heroku restart --app sre.com-production`

### Credo

`mix credo apps/sre/lib/sre/listing/view_helper.ex:160:23`


### Setting up environment

  * Install xcode: `xcode-select --install`
  * Install [Brew](http://brew.sh/)
  * Install dev dependencies: `brew install node heroku-toolbelt postgres elixir && brew cask install elm-platform`
  * Install/upgrade Hex and Rebar: `mix local.hex --force && mix local.rebar --force`
  * Clone Schema repo ([Schema](https://code.knledg.com/sre/schema)) and follow setup instructions.

### Initial App Setup

  * Copy `dev.env` to `.env` and fill in all the required environment variables (ask a developer for this information if you don't have it).
  * Run command `chmod +x .env`

### Starting App

  * (Local Postgres Docker instance needs to be running)
  * Setup env vars: `source .env`
  * Install app dependencies: `make install`
  * Start web app: `make server` (the whole app will need to be complied the first time you run this, so please be patient).

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### Deploying

1. Merge code changes into master branch
1. Bump version via mix file (`/apps/sre/mix.exs`)
1. Tag the changes with `git tag <version>`
1. Commit version bump
1. Push master
1. Deploy via heroku

## Error Troubleshooting

## Learn more About Phoenix

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: http://hexdocs.pm/phoenix
  * Source: https://github.com/phoenixframework/phoenix

## Creating UI Elements

- Inside apps/sre run this:
`mix ui.gen <top-level folder> <component>`
