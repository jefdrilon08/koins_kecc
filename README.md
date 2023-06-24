# KOINS

Microfinance and Microinsurance management system.

## Software Requirements

* Ruby on Rails version 7.x or higher
* PostgreSQL version 14.x or higher
* NodeJS version 16.x or higher with webpack

## First Time Setup

1. Acquire the source code from `https://github.com`.

```
git clone git@github.com:cloudband-solutions/koins.git
```

2. KOINS uses `dotenv-rails` gem to manage environment variables. Copy the `.env.dist` file to `.env` and make sure to change the values according to your environment

3. Setup the database and migrate the latest schema
```
bundle exec rails db:setup && bundle exec rails db:migrate
```

4. Install ruby and javascript dependencies:

```
bundle install
yarn install
```

5. As of **Rails 7**, the system uses `postcss` for compiling css and `esbuild` for javascript. Scripts to perform building is `package.json`. To run all components, use the `Profile` which can be easily ran using the following command:

```
./bin/dev
```

This will run the following (see `Procfile` for reference):

* `puma` application server
* sidekiq for operations
* sidekiq for accounting
* css compiler
* js compiler

## Scripts

* nginx systemd service: `scripts/nginx.service`

To initialize nginx via systemd:

```
sudo cp scripts/nginx.service /lib/systemd/system/nginx.service
sudo systemctl enable nginx
sudo systemctl start nginx
```

## Importing Database to Heroku (Deprecated)

In order for PG Backups to access and import your dump file you will need to upload it somewhere with an HTTP-accessible URL.

> Note that the `pg:backups restore` command drops any tables and other database objects before recreating them.

Generate a signed URL using the aws console:

```
aws s3 presign s3://your-bucket-address/your-object
```

Use the raw file URL in the pg:backups restore command:

```
heroku pg:backups:restore '<SIGNED URL>' DATABASE_URL
```

Transfer production database to staging:

```
heroku pg:copy koins-production DATABASE --remote staging
```

## Notes

### Create PostgreSQL user

1. Create a new user

```
sudo -u postgres createuser developer -P
```

2. Login to postgres

```
sudo su - postgres && psql
```

3. Alter role to Superuser

```
ALTER USER developer WITH SUPERUSER;
```

### Install Latest Redis on Ubuntu

1. Uninstall default version of redis-server:

```shell
sudo systemctl stop redis-server
sudo systemctl disable redis-server
sudo apt purge redis-server
```

2. Use following tutorial:

[Click here](https://redis.io/docs/getting-started/installation/install-redis-on-linux/)

3. Turn off protected mode (production)

From the redis server, enter the cli and issue the following command:

```
CONFIG SET protected-mode no
```

## Running Tests
