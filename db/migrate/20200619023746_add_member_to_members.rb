class AddMemberToMembers < ActiveRecord::Migration[6.0]
  def change
    add_reference :members, :member, null: true, foreign_key: true, type: :uuid
  end
end
