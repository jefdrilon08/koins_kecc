class AddCourseToKjspClaims < ActiveRecord::Migration[5.2]
  def change
  	add_column :kjsp_claims, :course, :string
  end
end
