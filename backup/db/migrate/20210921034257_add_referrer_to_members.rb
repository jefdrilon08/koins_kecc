class AddReferrerToMembers < ActiveRecord::Migration[6.1]
  def change
    add_reference :members, :referrer, null: true, foreign_key: true, type: :uuid
  end
end
