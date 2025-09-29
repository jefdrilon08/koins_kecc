class RenameMembershipArrangementsToTeaching < ActiveRecord::Migration[7.1]
  class MembershipArrangement < ApplicationRecord
    self.table_name = "membership_arrangements"
  end

  def up
    MembershipArrangement.where(name: "KA-GRASYA").update_all(name: "TEACHING")
    MembershipArrangement.where(name: "KA-ISA").update_all(name: "NON TEACHING")
  end

  def down
    MembershipArrangement.where(name: "TEACHING").update_all(name: "KA-GRASYA")
    MembershipArrangement.where(name: "NON TEACHING").update_all(name: "KA-ISA")
  end
end
