class CreateDwBranchNewMemberCounts < ActiveRecord::Migration[6.1]
  def change
    create_table :dw_branch_new_member_counts, id: :uuid do |t|
      t.references :branch, null: false, foreign_key: true, type: :uuid
      t.references :cluster, null: false, foreign_key: true, type: :uuid
      t.references :area, null: false, foreign_key: true, type: :uuid
      t.string :status
      t.jsonb :data
      t.integer :count_male
      t.integer :count_female
      t.integer :total

      t.timestamps
    end
  end
end
