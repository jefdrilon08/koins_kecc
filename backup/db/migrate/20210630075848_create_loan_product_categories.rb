class CreateLoanProductCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :loan_product_categories, id: :uuid do |t|
      t.string :name
      t.string :code

      t.timestamps
    end
  end
end
