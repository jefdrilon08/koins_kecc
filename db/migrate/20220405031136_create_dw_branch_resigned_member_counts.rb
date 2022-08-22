class CreateDwBranchResignedMemberCounts < ActiveRecord::Migration[6.1]
  def change
    create_table :dw_branch_resigned_member_counts, id: :uuid do |t|
      t.references :branch, null: false, foreign_key: true, type: :uuid
      t.references :cluster, null: false, foreign_key: true, type: :uuid
      t.references :area, null: false, foreign_key: true, type: :uuid
      t.integer :total
      t.integer :month
      t.integer :year

      t.timestamps
    end
  end
end
