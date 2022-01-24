class AddBranchIdtoTransferToTransferMemberRecord < ActiveRecord::Migration[6.1]
  def change
    add_column :transfer_member_records, :branch_id_to_transfer, :string
  end
end
