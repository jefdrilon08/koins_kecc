class AddCertificateForToMemberShares < ActiveRecord::Migration[6.1]
  def change
    add_column :member_shares, :certificate_for, :string
  end
end
