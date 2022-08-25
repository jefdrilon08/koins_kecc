class MoveExtensionsToHerokuExt < ActiveRecord::Migration[7.0]
  def up
    drop_stuff_that_uses_these_extensions!
    drop_extensions!

    create_heroku_ext_schema!

    create_extensions!(schema_name: "heroku_ext")
    recreate_stuff_that_uses_these_extensions!
  end

  def down
    drop_stuff_that_uses_these_extensions!
    drop_extensions!

    # Don't drop the `heroku_ext` schema, since it already exists in Heroku

    create_extensions!(schema_name: "public")
    recreate_stuff_that_uses_these_extensions!
  end

  private

  def drop_stuff_that_uses_these_extensions!
    execute <<~SQL
      -- Drop any objects that depend on objects owned by your extensions here
    SQL
  end

  def drop_extensions!
    execute <<~SQL
      DROP EXTENSION IF EXISTS btree_gist;
      DROP EXTENSION IF EXISTS tablefunc;
    SQL
  end

  def create_heroku_ext_schema!
    execute <<~SQL
      CREATE SCHEMA IF NOT EXISTS heroku_ext;
    SQL
  end

  def create_extensions!(schema_name:)
    execute <<~SQL
      CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA #{schema_name};
      CREATE EXTENSION IF NOT EXISTS tablefunc WITH SCHEMA #{schema_name};
    SQL
  end

  def recreate_stuff_that_uses_these_extensions!
    execute <<~SQL
      -- Recreate any objects dropped in order to drop the extensions
    SQL
  end

end
