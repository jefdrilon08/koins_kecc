class CreateLoanProductTagging < ActiveRecord::Migration[7.1]
  def change
    create_table :loan_product_taggings, id: :uuid do |t|

      t.string :name
      t.references :loan_product, null: false, foreign_key: true, type: :uuid

      t.timestamps

    end
  end
end
