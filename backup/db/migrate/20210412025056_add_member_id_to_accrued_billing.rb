class AddMemberIdToAccruedBilling < ActiveRecord::Migration[6.1]
  def change
    add_column :accrued_billings, :member_id, :string
  end
end
