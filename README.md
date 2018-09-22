# KOINS

Microfinance and Microinsurance management system.

## Software Requirements

* Ruby on Rails version 5.2.x or higher
* PostgreSQL version 9.x or higher
* NodeJS version 8.x or higher with webpack

## First Time Setup

1. Acquire the source code from `https://bitbucket.org`.

```
git clone https://bitbucket.org/cloudbandsolutions/koins.git
```

2. KOINS uses `dotenv-rails` gem to manage environment variables. Copy the `.env.dist` file to `.env` and make sure to change the values according to your environment

3. Setup the database and migrate the latest schema
```
bundle exec rails db:setup && bundle exec rails db:migrate
```

4. Install ruby and javascript dependencies:

```
bundle install
npm install
```

5. KOINS uses `react-js` for various javascript front-end interfaces. Source code is found in the directory `react`. Compile (and optionally `---watch`) the necessary react related assets:

```
./node_modules/.bin/webpack --watch
```

6. Run the server

```
bundle exec rails server
```
