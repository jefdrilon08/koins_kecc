class AddCenterIdToAccruedBilling < ActiveRecord::Migration[6.0]
  def change
    change_table(:accrued_billings) do |t|   
  		t.references :center, type: :uuid,  index: true, foreign_key: true
  		t.references :branch, type: :uuid,  index: true, foreign_key: true
    end
  end
end
