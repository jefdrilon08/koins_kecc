class AddEffectiveDateOfCoverageToHiipClaims < ActiveRecord::Migration[5.2]
  def change
    add_column :hiip_claims, :effective_date_of_coverage, :date
    add_column :hiip_claims, :expiration_date_of_coverage, :date
    add_column :hiip_claims, :date_admitted, :date
    add_column :hiip_claims, :date_discharged, :date
    add_column :hiip_claims, :number_ofdays_tobepaid, :string
    add_column :hiip_claims, :date_of_birth, :date
    add_column :hiip_claims, :age, :string
    add_column :hiip_claims, :reason_of_confinement, :text
    add_column :hiip_claims, :diagnosis, :text
    add_column :hiip_claims, :check_payee, :string

  end
end
