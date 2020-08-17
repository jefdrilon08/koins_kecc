class AddReasonToMemberMoratoriums < ActiveRecord::Migration[6.0]
  def change
    add_column :member_moratoria, :reason, :string
  end
end
