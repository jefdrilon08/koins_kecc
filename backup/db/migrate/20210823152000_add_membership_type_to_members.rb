class AddMembershipTypeToMembers < ActiveRecord::Migration[6.1]
  def change
    add_reference :members, :membership_type, null: true, foreign_key: true, type: :uuid
  end
end
