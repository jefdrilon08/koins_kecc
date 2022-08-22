class AddBranchToMonthlyClosingCollections < ActiveRecord::Migration[5.2]
  def change
    add_reference :monthly_closing_collections, :branch, type: :uuid, foreign_key: true
  end
end
