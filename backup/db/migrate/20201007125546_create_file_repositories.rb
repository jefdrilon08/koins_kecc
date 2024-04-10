class CreateFileRepositories < ActiveRecord::Migration[6.0]
  def change
    create_table :file_repositories, id: :uuid do |t|
      t.string :file_type

      t.timestamps
    end
  end
end
