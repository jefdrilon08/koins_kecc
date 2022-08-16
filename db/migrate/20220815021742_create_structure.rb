class CreateStructure < ActiveRecord::Migration[7.0]
  
  def change
    enable_extension 'pgcrypto'
    
    create_table :users, id: :uuid do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet     :current_sign_in_ip
      t.inet     :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at


      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true

    add_column :users, :username, :string
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :identification_number, :string
    add_column :users, :roles, :string

    create_table :active_storage_blobs do |t|
      t.string   :key,        null: false
      t.string   :filename,   null: false
      t.string   :content_type
      t.text     :metadata
      t.bigint   :byte_size,  null: false
      t.string   :checksum,   null: false
      t.datetime :created_at, null: false

      t.index [ :key ], unique: true
    end

    create_table :active_storage_attachments do |t|
      t.string     :name,     null: false
      t.references :record,   null: false, polymorphic: true, index: false
      t.references :blob,     null: false

      t.datetime :created_at, null: false

      t.index [ :record_type, :record_id, :name, :blob_id ], name: "index_active_storage_attachments_uniqueness", unique: true
    end

    create_table :areas, id: :uuid do |t|
      t.string :name
      t.string :short_name

      t.timestamps
    end
    create_table :clusters, id: :uuid do |t|
      t.references :area, type: :uuid, foreign_key: true
      t.string :name
      t.string :short_name

      t.timestamps
    end
    create_table :branches, id: :uuid do |t|
      t.references :cluster, type: :uuid, foreign_key: true
      t.string :name
      t.string :short_name

      t.timestamps
    end
    create_table :centers, id: :uuid do |t|
      t.references :branch, type: :uuid, foreign_key: true
      t.string :name
      t.string :short_name

      t.timestamps
    end
    create_table :accounting_codes, id: :uuid do |t|
      t.string :name
      t.string :code
      t.string :category
      t.json :data

      t.timestamps
    end
    create_table :announcements, id: :uuid do |t|
      t.string :title
      t.text :content
      t.references :user, type: :uuid, foreign_key: true

      t.timestamps
    end
    remove_column(:announcements, :user_id)
    add_column(:announcements, :user_id, :integer)
    remove_column(:announcements, :user_id, :integer)
    add_column(:announcements, :user_id, :uuid)
    create_table :members, id: :uuid do |t|
      t.references :center, type: :uuid, foreign_key: true
      t.references :branch, type: :uuid, foreign_key: true
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :gender
      t.date :date_of_birth
      t.string :civil_status
      t.string :home_number
      t.string :mobile_number
      t.string :processed_by
      t.string :approved_by
      t.string :identification_number
      t.string :place_of_birth
      t.string :status
      t.string :member_type
      t.string :religion
      t.string :insurance_status
      t.json :data
      t.date :date_resigned
      t.json :meta

      t.timestamps
    end
    create_table :accounting_entries, id: :uuid do |t|
      t.date :date_prepared
      t.date :date_posted
      t.references :branch, type: :uuid, foreign_key: true
      t.string :book
      t.string :reference_number
      t.string :particular
      t.string :approved_by
      t.string :prepared_by
      t.string :status
      t.json :data

      t.timestamps
    end
    create_table :journal_entries, id: :uuid do |t|
      t.string :post_type
      t.references :accounting_code, type: :uuid, foreign_key: true
      t.references :accounting_entry, type: :uuid, foreign_key: true
      t.json :data
      t.decimal :amount

      t.timestamps
    end
    create_table :project_type_categories, id: :uuid do |t|
      t.string :name
      t.string :code

      t.timestamps
    end
    create_table :project_types, id: :uuid do |t|
      t.string :name
      t.string :code
      t.references :project_type_category, type: :uuid, foreign_key: true

      t.timestamps
    end
    create_table :loan_products, id: :uuid do |t|
      t.string :name
      t.decimal :max_loan_amount
      t.decimal :min_loan_amount
      t.decimal :denomination
      t.boolean :insured
      t.boolean :is_entry_point
      t.decimal :monthly_interest_rate

      t.timestamps
    end
    add_column :loan_products, :data, :json
    create_table :loans, id: :uuid do |t|
      t.references :center, type: :uuid, foreign_key: true
      t.references :branch, type: :uuid, foreign_key: true
      t.date :date_prepared
      t.date :date_approved
      t.date :date_released
      t.date :date_completed
      t.references :member, type: :uuid, foreign_key: true
      t.decimal :principal
      t.decimal :interest
      t.decimal :principal_paid
      t.decimal :principal_balance
      t.decimal :interest_paid
      t.decimal :interest_balance
      t.string :status
      t.references :loan_product, type: :uuid, foreign_key: true
      t.string :term
      t.string :pn_number
      t.string :payment_type
      t.integer :num_installments
      t.decimal :monthly_interest_rate
      t.references :project_type, type: :uuid, foreign_key: true
      t.json :data

      t.timestamps
    end
    create_table :member_accounts, id: :uuid do |t|
      t.references :member, type: :uuid, foreign_key: true
      t.string :account_type
      t.string :account_subtype
      t.decimal :balance
      t.references :center, type: :uuid, foreign_key: true
      t.references :branch, type: :uuid, foreign_key: true
      t.string :status
      t.decimal :maintaining_balance

      t.timestamps
    end
    add_column :member_accounts, :data, :json
    create_table :amortization_schedule_entries, id: :uuid do |t|
      t.decimal :amount_due
      t.decimal :principal
      t.decimal :interest
      t.decimal :principal_paid
      t.decimal :interest_paid
      t.decimal :principal_balance
      t.decimal :interest_balance
      t.date :due_date
      t.boolean :is_paid
      t.references :loan, type: :uuid, foreign_key: true
      t.json :data

      t.timestamps
    end
    create_table :account_transactions, id: :uuid do |t|
      t.uuid :subsidiary_id
      t.string :subsidiary_type
      t.decimal :amount
      t.string :transaction_type
      t.datetime :transacted_at
      t.string :status
      t.json :data

      t.timestamps
    end
    create_table :account_transaction_collections, id: :uuid do |t|
      t.string :or_number
      t.decimal :total_amount
      t.references :center, type: :uuid, foreign_key: true
      t.references :branch, type: :uuid, foreign_key: true
      t.string :status
      t.datetime :transacted_at
      t.string :collection_type
      t.json :data

      t.timestamps
    end
    add_column :members, :access_token, :string
    create_table :activity_logs, id: :uuid do |t|
      t.string :content
      t.string :activity_type
      t.json :data

      t.timestamps
    end
    add_column :members, :signature_data, :text
    create_table :billings, id: :uuid do |t|
      t.date :collection_date
      t.references :center, type: :uuid, foreign_key: true
      t.references :branch, type: :uuid, foreign_key: true
      t.jsonb :data
      t.string :status

      t.timestamps
    end
    create_table :user_branches, id: :uuid do |t|
      t.uuid :user_id
      t.uuid :branch_id
      t.boolean :active

      t.timestamps
    end
    add_column :centers, :meeting_day, :integer
    create_table :data_stores, id: :uuid do |t|
      t.json :meta
      t.json :data

      t.timestamps
    end
    add_column :data_stores, :status, :string
    add_column :centers, :user_id, :uuid
    create_table :legal_dependents, id: :uuid do |t|
      t.string :first_name
      t.string :middle_name
      t.date :date_of_birth
      t.references :member, type: :uuid, foreign_key: true
      t.string :relationship
      t.json :data

      t.timestamps
    end
    add_column :legal_dependents, :last_name, :string
    create_table :beneficiaries, id: :uuid do |t|
      t.references :member, type: :uuid, foreign_key: true
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :relationship
      t.date :date_of_birth
      t.boolean :is_primary
      t.boolean :is_deceased

      t.timestamps
    end
    create_table :membership_payment_records, id: :uuid do |t|
      t.string :membership_type
      t.string :membership_name
      t.decimal :amount
      t.date :date_paid
      t.string :status
      t.references :member, type: :uuid, foreign_key: true

      t.timestamps
    end
    create_table :membership_payment_collections, id: :uuid do |t|
      t.date :collection_date
      t.references :center, type: :uuid, foreign_key: true
      t.references :branch, type: :uuid, foreign_key: true
      t.jsonb :data
      t.string :status

      t.timestamps
    end
    add_column :branches, :member_counter, :integer
    create_table :surveys, id: :uuid do |t|
      t.string :name
      t.boolean :published
      t.jsonb :data

      t.timestamps
    end
    remove_column :surveys, :published
    add_column :surveys, :status, :string
    create_table :survey_questions, id: :uuid do |t|
      t.references :survey, type: :uuid, foreign_key: true
      t.string :content
      t.string :question_type
      t.jsonb :data

      t.timestamps
    end

    add_column :survey_questions, :priority, :integer
    create_table :survey_answers, id: :uuid do |t|
      t.references :survey, type: :uuid, foreign_key: true
      t.jsonb :meta
      t.jsonb :data
      t.string :status

      t.timestamps
    end
    add_column :loans, :first_date_of_payment, :date
    create_table :member_shares, id: :uuid do |t|
      t.references :member, type: :uuid, foreign_key: true
      t.string :certificate_number
      t.jsonb :data

      t.timestamps
    end
    add_column :member_shares, :date_of_issue, :date
    add_column :loan_products, :priority, :integer
    add_column :members, :modifiable, :boolean
    create_table :deposit_collections, id: :uuid do |t|
      t.date :collection_date
      t.references :center, type: :uuid, foreign_key: true
      t.references :branch, type: :uuid, foreign_key: true
      t.jsonb :data
      t.string :status

      t.timestamps
    end
    create_table :withdrawal_collections, id: :uuid do |t|
      t.date :collection_date
      t.references :center, type: :uuid, foreign_key: true
      t.references :branch, type: :uuid, foreign_key: true
      t.jsonb :data
      t.string :status

      t.timestamps
    end
    create_table :monthly_closing_collections, id: :uuid do |t|
      t.date :closing_date
      t.date :closed_at
      t.jsonb :data
      t.jsonb :meta

      t.timestamps
    end
    add_reference :monthly_closing_collections, :branch, type: :uuid, foreign_key: true
    add_column :monthly_closing_collections, :status, :string
    add_column :loans, :cycle, :integer
    add_column :billings, :date_approved, :date
    add_column :deposit_collections, :date_approved, :date
    add_column :membership_payment_collections, :date_approved, :date
    add_column :withdrawal_collections, :date_approved, :date
    create_table :accounting_funds, id: :uuid do |t|
      t.string :name

      t.timestamps
    end
    add_reference :accounting_entries, :accounting_fund, foreign_key: true, type: :uuid
    add_column :membership_payment_records, :date_voided, :date
    add_column :monthly_closing_collections, :account_subtype, :string
    create_table :claims, id: :uuid do |t|
      	t.references :member, type: :uuid, foreign_key: true
    	  t.references :center, type: :uuid, foreign_key: true
        t.references :branch, type: :uuid, foreign_key: true
      	t.date :date_prepared
      	t.string :policy_number
      	t.string :type_of_insurance_policy
      	t.string :name_of_insured
      	t.string :beneficiary
      	t.string :classification_of_insured
      	t.date :date_of_birth
      	t.string :gender
      	t.date :date_of_policy_issue
      	t.decimal :face_amount
      	t.date :date_of_death_tpd_accident
      	t.decimal :arrears
      	t.text :cause_of_death_tpd_accident
      	t.decimal :amount_benefit_payable
      	t.decimal :equity_value
      	t.decimal :retirement_fund
      	t.string :prepared_by
      	t.string :length_of_stay
      	t.decimal :returned_contribution
      	t.decimal :total_amount_payable
      	t.string :order_of_child
      	t.string :category_of_cause_of_death_tpd_accident
      	t.date :date_reported
      	t.date :date_paid
      	t.timestamps null: false
    end
    add_column :member_shares, :is_void, :boolean
    add_column :loans, :maturity_date, :date
    add_column :members, :previous_date_resigned, :date
    create_table :clip_claims, id: :uuid do |t|
    	  t.references :member, type: :uuid, foreign_key: true
    	  t.references :center, type: :uuid, foreign_key: true
        t.references :branch, type: :uuid, foreign_key: true
      	t.date :date_prepared
      	t.string :creditors_name
      	t.string :policy_number
      	t.date :date_of_birth
      	t.string :member_name
      	t.string :beneficiary
      	t.string :gender
      	t.string :age
      	t.date :date_of_death
      	t.text :cause_of_death
		    t.date :effective_date_of_coverage
		    t.date :expiration_date_of_coverage      	
      	t.decimal :amount_of_loan
      	t.string :terms
      	t.decimal :amount_payable_to_beneficiary
      	t.string :prepared_by
      	t.decimal :amount_payable_to_creditor
    	  t.string :type_of_loan
      	t.timestamps null: false
    end
    create_table :member_account_validations, id: :uuid do |t|
    	t.references :branch, type: :uuid, foreign_key: true
    	t.date :date_prepared
      	t.string :status
      	t.string :prepared_by
      	t.string :approved_by
      	t.text :particular
      	t.string :reference_number
      	t.decimal :total
      	t.string :or_number
      	t.date :date_approved
      	t.date :date_validated
      	t.string :validated_by
      	t.date :date_checked
      	t.string :checked_by
      	t.date :date_cancelled
      	t.string :cancelled_by
      	t.boolean :is_remote
      	t.decimal :total_rf
      	t.decimal :total_50_percent_lif
      	t.decimal :total_advance_lif
      	t.decimal :total_advance_rf
      	t.decimal :total_interest
      	t.decimal :total_equity_interest

      t.timestamps
    end
    create_table :member_account_validation_records, id: :uuid do |t|
    	t.references :member_account_validation, type: :uuid, foreign_key: true, index: {:name => "index_member_account_validation_records_uniqueness"}
    	t.references :member, type: :uuid, foreign_key: true
    	t.references :center, type: :uuid, foreign_key: true
      t.string :status
      t.string :transaction_number
      t.decimal :rf
      t.decimal :lif_50_percent
      t.decimal :advance_rf
      t.decimal :interest
      t.decimal :equity_interest
      t.decimal :total
      t.date :resignation_date
      t.string :member_classification
      	
      t.timestamps
    end
    create_table :member_account_validation_cancellations, id: :uuid do |t|
    	t.references :member_account_validation, type: :uuid, foreign_key: true, index: {:name => "index_member_account_validation_cancellations_uniqueness"}
    	t.references :member, type: :uuid, foreign_key: true
    	t.references :branch, type: :uuid, foreign_key: true
      	t.text :reason
      	t.date :date_cancelled

      t.timestamps
    end
  	add_column :member_account_validation_records, :advance_lif, :decimal
  	add_column :member_account_validation_records, :data, :json
  	add_column :member_account_validations, :data, :json
	    if column_exists? :claims, :member_id
            remove_column :claims, :member_id
      end
      if column_exists? :claims, :center_id
              remove_column :claims, :center_id
      end
      if column_exists? :claims, :branch_id
              remove_column :claims, :branch_id
      end
  	change_table(:claims) do |t|   
  		t.references :member, type: :uuid,  index: true, foreign_key: true
  		t.references :center, type: :uuid,  index: true, foreign_key: true
  		t.references :branch, type: :uuid,  index: true, foreign_key: true
    end
    create_table :adjustment_records, id: :uuid do |t|
      t.jsonb :meta
      t.jsonb :data
      t.string :status

      t.timestamps
    end
    add_column :adjustment_records, :adjustment_type, :string
    create_table :insurance_withdrawal_collections, id: :uuid do |t|
      t.date :collection_date
      t.references :center, type: :uuid, foreign_key: true
      t.references :branch, type: :uuid, foreign_key: true
      t.jsonb :data
      t.string :status
      t.date :date_approved

      t.timestamps
    end
    add_column :adjustment_records, :date_approved, :date
    add_column :adjustment_records, :approved_by, :string
    create_table :insurance_fund_transfer_collections, id: :uuid do |t|
      t.date :collection_date
      t.references :center, type: :uuid, foreign_key: true
      t.references :branch, type: :uuid, foreign_key: true
      t.jsonb :data
      t.string :status
      t.date :date_approved
      
      t.timestamps
    end
    create_table :attachment_files, id: :uuid do |t|
      t.references :member, type: :uuid, foreign_key: true
      t.string :file_name
      t.jsonb :data

      t.timestamps
    end
    create_table :time_deposit_collections, id: :uuid do |t|
      t.date :collection_date
      t.references :center, foreign_key: true, type: :uuid
      t.references :branch, foreign_key: true, type: :uuid
      t.jsonb :data
      t.string :status
      t.date :date_approved

      t.timestamps
    end
    add_column :members, :insurance_date_resigned, :date
    add_column :member_shares, :number_of_shares, :integer
    create_table :hiip_claims, id: :uuid do |t|
  	    t.references :member, type: :uuid, foreign_key: true
  	    t.references :center, type: :uuid, foreign_key: true
        t.references :branch, type: :uuid, foreign_key: true
        t.date :date_posted
        t.decimal :amount
        t.text :mode_of_payment

      t.timestamps
    end
    add_column :hiip_claims, :policy_number, :string
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
  	add_column :hiip_claims, :prepared_by, :string
  	add_column :hiip_claims, :balance, :decimal
    add_index :account_transactions, :transacted_at
    add_index :account_transactions, :transaction_type
    create_table :loan_repayment_rates, id: :uuid do |t|
      t.references :loan, foreign_key: true, type: :uuid
      t.date :as_of
      t.references :branch, foreign_key: true, type: :uuid
      t.references :center, foreign_key: true, type: :uuid
      t.jsonb :data

      t.timestamps
    end
    #CREATE INDEX testindex ON account_transactions (transacted_at, subsidiary_id) WHERE transaction_type = 'loan_payment' AND subsidiary_type = 'Loan' AND amount > 0;
    add_index(
      :account_transactions, 
      [:transacted_at, :subsidiary_id], 
      name: 'index_account_transactions_loan_payments', 
      where: "(transaction_type = 'loan_payment' AND subsidiary_type = 'Loan' AND amount > 0)"
    )
    add_index(
      :account_transactions, 
      [:subsidiary_id, :transaction_type, :transacted_at], 
      name: 'idx_account_transactions_soa_personal_funds', 
      where: "(amount > 0)"
    )
    add_index(
      :amortization_schedule_entries,
      [:loan_id, :due_date],
      name: 'idx_amortization_schedule_entries_loans'
    )
    add_index(
      :amortization_schedule_entries,
      [:loan_id, :due_date],
      name: 'idx_amortization_schedule_entries_loans_principal_interest',
      where: "(interest > 0 AND principal > 0)"
    )
  	remove_column :active_storage_attachments, :record_id, :bigint
  	add_column :active_storage_attachments, :record_id, :uuid
    create_table :kalinga_claims, id: :uuid do |t|
    	t.references :member, type: :uuid, foreign_key: true
    	t.references :center, type: :uuid, foreign_key: true
        t.references :branch, type: :uuid, foreign_key: true
        t.date :date_reported
        t.date :date_emailed
        t.date :date_approved
        t.date :date_requested
        t.string :purpose
        t.decimal :amount
        t.date :effective_date
        t.date :expiration_date
        t.string :poc_number
        t.string :name_of_insured
        t.string :relationship_to_member
        t.string :name_of_payee
        t.boolean :is_member
        t.string :insured_address
        t.string :civil_status
        t.date :date_of_birth
        t.string :name_of_beneficiary
        t.date :date_of_death_or_incident
        t.text :reason_of_death
        t.string :gender
        t.string :prepared_by
     
      t.timestamps
    end
  	add_column :kalinga_claims, :issueddate, :date
  	 remove_reference :kalinga_claims, :member, index: true, foreign_key: true
  	 remove_reference :kalinga_claims, :branch, index: true, foreign_key: true
  	 remove_reference :kalinga_claims, :center, index: true, foreign_key: true
  	remove_column :kalinga_claims, :name_of_payee, :string
    add_column :kalinga_claims, :name_of_member, :string
  	add_column :kalinga_claims, :member_branch, :string
  	add_column :kalinga_claims, :member_identification_number, :string
    create_table :kbente_claims, id: :uuid do |t|
    	t.references :member, type: :uuid, foreign_key: true
    	t.references :center, type: :uuid, foreign_key: true
        t.references :branch, type: :uuid, foreign_key: true
        t.date :date_reported
        t.date :date_emailed
        t.date :date_approved
        t.date :date_requested
        t.string :purpose
        t.decimal :amount
        t.string :prepared_by
        t.string :name_of_insured
        t.string :name_of_beneficiary
        t.string :classification
        t.date :date_of_death
      t.timestamps
    end
    create_table :kjsp_claims, id: :uuid do |t|
    	t.references :member, type: :uuid, foreign_key: true
    	t.references :center, type: :uuid, foreign_key: true
        t.references :branch, type: :uuid, foreign_key: true
    	t.date :date_prepared
    	t.string :name_of_kjsp_beneficiary
    	t.string :payee
    	t.string :amount
    	t.string :name_of_school
    	t.string :school_year
    	t.string :year_level
    	t.string :sem
    	t.string :kjsp_type
    	t.string :final_grade
    	t.string :remarks
      t.timestamps
    end
  	add_column :kjsp_claims, :classification, :string
  	add_column :kjsp_claims, :received_by, :string
  	add_column :kjsp_claims, :prepared_by, :string
  	remove_column :kalinga_claims, :is_member, :boolean
    create_table :calamity_claims, id: :uuid do |t|
    	t.references :member, type: :uuid, foreign_key: true
    	t.references :center, type: :uuid, foreign_key: true
        t.references :branch, type: :uuid, foreign_key: true
        t.date :date_requested
        t.date :purpose
        t.date :type_of_calamity
        t.date :amount
        t.date :date_of_event
        t.date :date_approved
        t.date :date_of_notification
        t.date :name_of_payee
        t.date :name_of_beneficiary
        t.date :prepared_by
      t.timestamps
    end
  	change_column :calamity_claims, :purpose, :string
  	change_column :calamity_claims, :type_of_calamity, :string
  	change_column :calamity_claims, :amount, :string
  	change_column :calamity_claims, :name_of_payee, :string
  	change_column :calamity_claims, :name_of_beneficiary, :string
  	change_column :calamity_claims, :prepared_by, :string
    add_column :loans, :max_active_date, :date
    add_column :loans, :user_id, :uuid
  	add_column :kjsp_claims, :course, :string
  	add_column :claims, :claim_type, :string
  	add_column :claims, :data, :json
  	add_column :clip_claims, :claim_type, :string
  	add_column :clip_claims, :data, :json
  	add_column :hiip_claims, :claim_type, :string
  	add_column :hiip_claims, :data, :json
    add_column :hiip_claims, :date_prepared, :date
  	add_column :kalinga_claims, :claim_type, :string
  	add_column :kalinga_claims, :data, :json
  	add_column :calamity_claims, :claim_type, :string
  	add_column :calamity_claims, :data, :json
  	add_column :kbente_claims, :claim_type, :string
  	add_column :kbente_claims, :data, :json
  	add_column :kjsp_claims, :claim_type, :string
  	add_column :kjsp_claims, :data, :json
  	add_column :kalinga_claims, :member_center, :string
      if column_exists? :kalinga_claims, :name_of_member
              remove_column :kalinga_claims, :name_of_member
      end
      
      if column_exists? :kalinga_claims, :member_identification_number
              remove_column :kalinga_claims, :member_identification_number
      end

      if column_exists? :kalinga_claims, :member_branch
              remove_column :kalinga_claims, :member_branch
      end

      if column_exists? :kalinga_claims, :member_center
              remove_column :kalinga_claims, :member_center
      end

    change_table(:kalinga_claims) do |t|   
      t.references :member, type: :uuid,  index: true, foreign_key: true
      t.references :center, type: :uuid,  index: true, foreign_key: true
      t.references :branch, type: :uuid,  index: true, foreign_key: true
    end
    create_table :savings_insurance_transfer_collections, id: :uuid do |t|
      t.string :status
      t.references :center, foreign_key: true, type: :uuid
      t.references :branch, foreign_key: true, type: :uuid
      t.date :collection_date
      t.date :date_approved
      t.jsonb :data

      t.timestamps
    end

    # CREATE INDEX compute_interest1 ON account_transactions (subsidiary_id, transacted_at) WHERE transaction_type IN ('deposit', 'withdrawal') AND NOT (data->>'is_interest' = 'true');
    add_index(
      :account_transactions,
      [:subsidiary_id, :transacted_at],
      name: 'idx_compute_interest1',
      where: "transaction_type IN ('deposit', 'withdraw') AND NOT (data->>'is_interest' = 'true')"
    )


    add_column :savings_insurance_transfer_collections, :total_amount, :decimal, precision: 8, scale: 2, default: 0.00
    add_column :savings_insurance_transfer_collections, :approved_by, :string
    add_column :users, :is_regular, :boolean
    add_column :users, :incentivized_date, :date
  	add_column :claims, :status, :string
    create_table :user_demerits, id: :uuid do |t|
      t.references :user, foreign_key: true, type: :uuid
      t.references :branch, foreign_key: true, type: :uuid
      t.string :status
      t.string :demerit_type
      t.string :role
      t.date :date_prepared
      t.date :date_approved
      t.date :date_of_action
      t.text :reason
      t.text :explanation
      t.json :data

      t.timestamps
    end
    add_column :loans, :original_maturity_date, :date
  	add_column :claims, :approved_by, :string
  	add_column :claims, :amount, :decimal
    add_column :loans, :is_restructured, :boolean
  	remove_column :claims, :amount, :decimal
    create_table :equity_withdrawal_collections, id: :uuid do |t|
      t.date :collection_date
      t.references :center, type: :uuid, foreign_key: true
      t.references :branch, type: :uuid, foreign_key: true
      t.jsonb :data
      t.string :status
      t.date :date_approved

      t.timestamps
    end
    
    return if foreign_key_exists?(:active_storage_attachments, column: :blob_id)

    if table_exists?(:active_storage_blobs)
      add_foreign_key :active_storage_attachments, :active_storage_blobs, column: :blob_id
    end
  	add_column :member_account_validation_records, :equity_value, :decimal
  	add_column :member_account_validation_records, :policy_loan, :decimal
  	add_column :member_account_validations, :total_policy_loan, :decimal
    add_reference :members, :member, null: true, foreign_key: true, type: :uuid
    create_table :claim_attachment_files, id: :uuid do |t|
      t.references :claim, type: :uuid, foreign_key: true
      t.string :file_name
      t.jsonb :data	

      t.timestamps
    end
    create_table :member_moratoria, id: :uuid do |t|
      t.string :status
      t.references :branch, null: false, foreign_key: true, type: :uuid
      t.references :center, null: false, foreign_key: true, type: :uuid
      t.references :member, null: false, foreign_key: true, type: :uuid
      t.date :date_initialized
      t.integer :number_of_daynumber_of_days
      t.jsonb :data

      t.timestamps
    end
    create_table :member_loan_moratoria, id: :uuid do |t|
      t.references :member_moratorium, foreign_key: true, type: :uuid
      t.references :loan, null: false, foreign_key: true, foreign_key: true, type: :uuid
      t.references :branch, null: false, foreign_key: true, type: :uuid
      t.references :center, null: false, foreign_key: true, type: :uuid
      t.references :member, null: false, foreign_key: true, type: :uuid
      t.date :date_initialized
      t.integer :number_of_daynumber_of_days
      t.string :status
      t.jsonb :data

      t.timestamps
    end
    remove_column :member_moratoria, :number_of_daynumber_of_days
    add_column :member_moratoria, :number_of_days, :integer
    remove_column :member_loan_moratoria, :number_of_daynumber_of_days
    add_column :member_loan_moratoria, :number_of_days, :integer
    add_column :member_moratoria, :reason, :string
    add_column :member_loan_moratoria, :reason, :string
  	add_column :claims, :checked_by, :string
  	add_column :claims, :date_checked, :date
  	add_column :claims, :date_approved, :date
    add_index(
      :billings, 
      [:status, :collection_date], 
      name: 'idx_billings_status_collection_date'
    )
  	add_column :claims, :posted_by, :string
  	add_column :claims, :date_posted, :date
    create_table :file_repositories, id: :uuid do |t|
      t.string :file_type

      t.timestamps
    end
    add_column :branches, :current_date, :date
    create_table :equity_value_interests, id: :uuid do |t|
      t.references :member_account, type: :uuid, foreign_key: true
      t.references :account_transaction, type: :uuid, foreign_key: true
      t.date :month_of_year_date
      t.decimal :interest_amount

      t.timestamps
    end
  	if foreign_key_exists?(:claims, :members)
      remove_foreign_key :claims, :members
    end
    create_table :accrued_interests, id: :uuid do |t|
      t.string :branch
      t.string :center
      t.string :member
      t.date :cut_off_date
      t.date :start_date
      t.date :end_date
      t.string :number_of_days
      t.string :accrued_type
      t.string :status

      t.timestamps
    end
    add_column :accrued_interests, :data, :json
    add_column :accrued_interests, :number_of_moratoium_day, :string
    create_table :accrued_billings, id: :uuid do |t|
      t.date :collection_date
      t.json :data
      t.string :status
      t.date :date_approved

      t.timestamps
    end
    change_table(:accrued_billings) do |t|   
  		t.references :center, type: :uuid,  index: true, foreign_key: true
  		t.references :branch, type: :uuid,  index: true, foreign_key: true
    end
    create_table :recompute_restructures, id: :uuid do |t|
      t.string :branch, null: false, foreign_key: true
      t.string :center, null: false, foreign_key: true
      t.string :status
      t.date :transaction_date
      t.json :data

      t.timestamps
    end
    add_column :recompute_restructures, :member, :string
    add_column :recompute_restructures, :loan, :string
    create_table :daily_branch_metrics, id: :uuid do |t|
      t.decimal :principal
      t.decimal :interest
      t.decimal :total
      t.decimal :principal_due
      t.decimal :interest_due
      t.decimal :total_due
      t.decimal :principal_paid
      t.decimal :interest_paid
      t.decimal :principal_paid_due
      t.decimal :portfolio
      t.decimal :interest_paid_due
      t.decimal :total_paid_due
      t.decimal :total_paid
      t.decimal :principal_balance
      t.decimal :interest_balance
      t.decimal :total_balance
      t.decimal :overall_principal_balance
      t.decimal :overall_interest_balance
      t.decimal :overall_balance
      t.decimal :principal_rr
      t.decimal :interest_rr
      t.decimal :total_rr
      t.decimal :par_amount
      t.decimal :par
      t.integer :num_days_par
      t.string :status

      t.date :as_of
      t.jsonb :data
      t.references :branch, null: false, foreign_key: true, type: :uuid
      t.references :cluster, null: false, foreign_key: true, type: :uuid
      t.references :area, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
    add_column :data_stores, :as_of, :date
    add_column :data_stores, :start_date, :date
    add_column :data_stores, :end_date, :date
    create_table :active_storage_variant_records do |t|
      t.belongs_to :blob, null: false, index: false
      t.string :variation_digest, null: false

      t.index %i[ blob_id variation_digest ], name: "index_active_storage_variant_records_uniqueness", unique: true
      t.foreign_key :active_storage_blobs, column: :blob_id
    end
    add_column :billings, :or_number, :string
    add_column :billings, :ar_number, :string
    add_column :billings, :total_collected, :decimal
    add_column :billings, :total_expected_collections, :decimal
    add_column :membership_payment_collections, :or_number, :string
    add_column :membership_payment_collections, :ar_number, :string
    add_column :membership_payment_collections, :total_collected, :decimal
    add_column :journal_entries, :book, :string
    add_reference :journal_entries, :branch, foreign_key: true, type: :uuid
    add_reference :journal_entries, :accounting_fund, foreign_key: true, type: :uuid
    add_column :journal_entries, :status, :string
    add_column :journal_entries, :date_posted, :date
    add_column :journal_entries, :date_prepared, :date
    remove_column :journal_entries, :date_posted
    add_column :journal_entries, :ae_date_posted, :date
    create_table :accounting_code_balances, id: :uuid do |t|
      t.references :accounting_code, null: false, foreign_key: true, type: :uuid
      t.references :accounting_fund, foreign_key: true, type: :uuid
      t.references :branch, null: false, foreign_key: true, type: :uuid
      t.string :category
      t.date :start_date
      t.date :end_date
      t.decimal :total_beginning_debit
      t.decimal :total_beginning_credit
      t.decimal :total_current_debit
      t.decimal :total_current_credit
      t.decimal :total_ending_debit
      t.decimal :total_ending_credit

      t.timestamps
    end

    add_index(
      :accounting_code_balances,
      [:accounting_code_id, :category, :branch_id, :start_date, :end_date],
      name: 'idx_acb_ac_id_cat_branch_id_sd_ed'
    )
    
    add_column :accounting_code_balances, :status, :string
    create_table :monthly_accounting_code_summaries, id: :uuid do |t|
      t.integer :month
      t.integer :year
      t.references :branch, null: false, foreign_key: true, type: :uuid
      t.references :accounting_code, null: false, foreign_key: true, type: :uuid
      t.string :category
      t.string :name
      t.decimal :dr_amount
      t.decimal :cr_amount

      t.timestamps
    end

    add_index(
      :monthly_accounting_code_summaries,
      [:month, :year, :accounting_code_id, :branch_id],
      name: 'idx_macs_m_y_ac_id_b_id'
    )
    add_column :branches, :color, :string
    create_table :member_account_daily_statements, id: :uuid do |t|
      t.references :member, null: false, foreign_key: true, type: :uuid
      t.references :member_account, null: false, foreign_key: true, type: :uuid
      t.date :transacted_at
      t.references :branch, null: false, foreign_key: true, type: :uuid
      t.decimal :debit_amount
      t.decimal :credit_amount

      t.timestamps
    end

    add_index(
      :member_account_daily_statements,
      [:member_id, :member_account_id, :branch_id, :transacted_at],
      name: 'idx_macds_m_ma_b_t'
    )
    add_column :member_shares, :certificate_for, :string
  	rename_table :equity_value_interests, :interests
  	add_column :interests, :type, :string
    add_column :accrued_billings, :member_id, :string
    add_column :users, :access_token, :string
    add_column :members, :encrypted_password, :string
    add_column :members, :username, :string
    create_table :online_applications, id: :uuid do |t|
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :gender
      t.date :date_of_birth
      t.string :civil_status
      t.string :home_number
      t.string :mobile_number
      t.string :reference_number
      t.string :status
      t.string :place_of_birth
      t.string :religion
      t.jsonb :data

      t.timestamps
    end
    create_table :online_application_documents, id: :uuid do |t|
      t.string :file_name
      t.jsonb :data
      t.references :online_application, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
    add_reference :members, :online_application, null: true, foreign_key: true, type: :uuid
    add_index(
      :online_applications,
      :reference_number,
      name: 'idx_online_applications_reference_number'
    )
    add_reference :online_applications, :branch, null: true, foreign_key: true, type: :uuid
    add_column :branches, :is_main, :boolean
    add_column :online_applications, :agreed_to_dp_terms, :boolean
    add_index(
      :online_applications,
      :mobile_number,
      name: 'idx_mobile_number_oa'
    )
  	rename_column :interests, :type, :interest_type
    create_table :loan_product_categories, id: :uuid do |t|
      t.string :name
      t.string :code

      t.timestamps
    end
    add_reference :loan_products, :loan_product_category, null: true, foreign_key: true, type: :uuid
    create_table :membership_arrangements, id: :uuid do |t|
      t.string :name
      t.jsonb :data

      t.timestamps
    end
    create_table :membership_types, id: :uuid do |t|
      t.string :name
      t.jsonb :data

      t.timestamps
    end
    add_reference :members, :membership_arrangement, null: true, foreign_key: true, type: :uuid
    add_reference :members, :membership_type, null: true, foreign_key: true, type: :uuid
    add_reference :online_applications, :membership_type, null: true, foreign_key: true, type: :uuid
    add_reference :online_applications, :membership_arrangement, null: true, foreign_key: true, type: :uuid
    create_table :insurance_monthly_closing_collections, id: :uuid do |t|
      t.references :branch, type: :uuid, foreign_key: true
      t.date :closing_date
      t.date :closed_at
      t.jsonb :data
      t.jsonb :meta
      t.string :status
      t.string :account_subtype

      t.timestamps
    end
    add_reference :online_applications, :center, null: true, foreign_key: true, type: :uuid
    create_table :referrers, id: :uuid do |t|
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :status
      t.string :contact_number
      t.jsonb :data

      t.timestamps
    end
    add_reference :members, :referrer, null: true, foreign_key: true, type: :uuid
    add_column :referrers, :date_registered, :date
    add_column :referrers, :category, :string
    add_column :members, :coordinator_id, :uuid
    create_table :make_payments, id: :uuid do |t|
      t.references :member, null: false, foreign_key: true, type: :uuid
      t.date :transaction_date
      t.date :date_approve
      t.string :approved_by
      t.string :created_by
      t.json :data
      t.string :status

      t.timestamps
    end
    create_table :transfer_member_records, id: :uuid do |t|
      t.string :branch_id
      t.date :transfer_date
      t.string :status
      t.date :date_approved
      t.json :data

      t.timestamps
    end
    add_column :make_payments, :make_payment_type, :string
    add_column :make_payments, :meta, :json
    add_column :transfer_member_records, :branch_id_to_transfer, :string
    create_table :loan_product_types, id: :uuid do |t|
      t.string :name
      t.references :loan_product, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
    add_reference :loans, :loan_product_type, null: true, foreign_key: true, type: :uuid
    create_table :commission_collections, id: :uuid do |t|
      t.date :start_date
      t.date :end_date
      t.date :date_approved
      t.date :date_prepared
      t.jsonb :data
      t.jsonb :meta
      t.string :status
      t.string :category

      t.timestamps
    end
    add_column :members, :email, :string
    add_column :online_applications, :email, :string
    create_table :messages, id: :uuid do |t|
      t.string :topic
      t.text :content
      t.references :member, null: false, foreign_key: true, type: :uuid
      t.string :status
      t.references :message, null: true, foreign_key: true, type: :uuid
      t.jsonb :data

      t.timestamps
    end
    add_reference :messages, :user, null: true, foreign_key: true, type: :uuid
    add_column :announcements, :status, :string
    add_column :announcements, :is_published, :boolean
    add_reference :announcements, :branch, null: true, foreign_key: true, type: :uuid
    add_column :announcements, :announced_at, :date
    add_column :announcements, :published_at, :date
    create_table :dw_branch_member_counts, id: :uuid do |t|
      t.references :branch, null: false, foreign_key: true, type: :uuid
      t.references :cluster, null: false, foreign_key: true, type: :uuid
      t.references :area, null: false, foreign_key: true, type: :uuid
      t.string :status
      t.date :as_of
      t.integer :count
      t.jsonb :data

      t.timestamps
    end
    add_column :dw_branch_member_counts, :gender, :string
    remove_column :dw_branch_member_counts, :gender
    remove_column :dw_branch_member_counts, :count

    add_column :dw_branch_member_counts, :count_male, :integer
    add_column :dw_branch_member_counts, :count_female, :integer
    add_column :dw_branch_member_counts, :total, :integer
    create_table :dw_branch_active_loan_counts, id: :uuid do |t|
      t.references :branch, null: false, foreign_key: true, type: :uuid
      t.references :cluster, null: false, foreign_key: true, type: :uuid
      t.references :area, null: false, foreign_key: true, type: :uuid
      t.string :status
      t.date :as_of
      t.jsonb :data
      t.integer :total

      t.timestamps
    end
    create_table :dw_branch_loan_product_active_loan_counts, id: :uuid do |t|
      t.references :branch, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_b_lp_alc_index' }
      t.references :cluster, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_c_lp_alc_index' }
      t.references :area, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_a_lp_alc_index' }
      t.string :status
      t.date :as_of
      t.jsonb :data
      t.integer :total
      t.references :loan_product, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_lp_alc_index' }
      t.references :loan_product_category, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_lpc_alc_index' }

      t.timestamps
    end
    create_table :dw_branch_new_member_counts, id: :uuid do |t|
      t.references :branch, null: false, foreign_key: true, type: :uuid
      t.references :cluster, null: false, foreign_key: true, type: :uuid
      t.references :area, null: false, foreign_key: true, type: :uuid
      t.string :status
      t.jsonb :data
      t.integer :count_male
      t.integer :count_female
      t.integer :total

      t.timestamps
    end
    create_table :dw_branch_loan_product_outstanding_loan_amounts, id: :uuid do |t|
      t.references :branch, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_b_lp_ola_index' }
      t.references :cluster, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_b_lp_c_ola_index' }
      t.references :area, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_b_lp_a_ola_index' }
      t.string :status
      t.jsonb :data
      t.decimal :amount
      t.references :loan_product_category, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_b_lp_lpc_ola_index' }
      t.references :loan_product, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_b_lp_lp_ola_index' }
      t.date :as_of

      t.timestamps
    end
    create_table :dw_branch_monthly_loan_product_disbursed_counts, id: :uuid do |t|
      t.references :branch, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_b_m_lpdc_index' }
      t.references :area, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_a_m_lpdc_index' }
      t.references :cluster, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_c_m_lpdc_index' }
      t.references :loan_product, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_lp_m_lpdc_index' }
      t.references :loan_product_category, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_lpc_m_lpdc_index' }
      t.integer :month
      t.integer :year
      t.string :status
      t.integer :total
      t.jsonb :data

      t.timestamps
    end
    add_column :dw_branch_monthly_loan_product_disbursed_counts, :amount, :decimal
    create_table :dw_branch_monthly_loan_amount_collections, id: :uuid do |t|
      t.references :branch, null: false, foreign_key: true, type: :uuid
      t.references :area, null: false, foreign_key: true, type: :uuid
      t.references :cluster, null: false, foreign_key: true, type: :uuid
      t.decimal :amount
      t.jsonb :data
      t.string :status
      t.integer :month
      t.integer :year

      t.timestamps
    end
    create_table :dw_branch_monthly_loan_amount_dues, id: :uuid do |t|
      t.references :branch, null: false, foreign_key: true, type: :uuid
      t.references :area, null: false, foreign_key: true, type: :uuid
      t.references :cluster, null: false, foreign_key: true, type: :uuid
      t.decimal :amount
      t.jsonb :data
      t.string :status
      t.integer :month
      t.integer :year

      t.timestamps
    end
    create_table :dw_branch_loan_past_dues, id: :uuid do |t|
      t.references :branch, null: false, foreign_key: true, type: :uuid
      t.references :area, null: false, foreign_key: true, type: :uuid
      t.references :cluster, null: false, foreign_key: true, type: :uuid
      t.decimal :amount
      t.jsonb :data
      t.string :record_type
      t.string :status
      t.integer :month
      t.integer :year

      t.timestamps
    end
    create_table :dw_branch_par_amounts, id: :uuid do |t|
      t.references :branch, null: false, foreign_key: true, type: :uuid
      t.references :area, null: false, foreign_key: true, type: :uuid
      t.references :cluster, null: false, foreign_key: true, type: :uuid
      t.decimal :amount
      t.jsonb :data
      t.string :record_type
      t.string :status
      t.integer :month
      t.integer :year

      t.timestamps
    end
    add_column :dw_branch_active_loan_counts, :month, :integer
    add_column :dw_branch_active_loan_counts, :year, :integer
    add_column :dw_branch_loan_product_active_loan_counts, :month, :integer
    add_column :dw_branch_loan_product_active_loan_counts, :year, :integer
    add_column :dw_branch_member_counts, :record_type, :string
    add_column :dw_branch_member_counts, :count_others, :integer
    add_column :dw_branch_member_counts, :month, :integer
    add_column :dw_branch_member_counts, :year, :integer
    add_column :dw_branch_new_member_counts, :month, :integer
    add_column :dw_branch_new_member_counts, :year, :integer
    create_table :dw_branch_resigned_member_counts, id: :uuid do |t|
      t.references :branch, null: false, foreign_key: true, type: :uuid
      t.references :cluster, null: false, foreign_key: true, type: :uuid
      t.references :area, null: false, foreign_key: true, type: :uuid
      t.integer :total
      t.integer :month
      t.integer :year

      t.timestamps
    end
    remove_column :dw_branch_new_member_counts, :count_male
    remove_column :dw_branch_new_member_counts, :count_female
    change_column_null(:active_storage_blobs, :checksum, true)
    add_column :branches, :or_prefix, :string
    add_column :branches, :or_counter, :integer, default: 0
    add_column :branches, :or_current_max, :integer
    add_column :branches, :ar_prefix, :string
    add_column :branches, :ar_counter, :integer, default: 0
    add_column :branches, :ar_current_max, :integer
    create_table :administration_branch_closing_records, id: :uuid do |t|
      t.references :data_store, null: false, foreign_key: true, type: :uuid
      t.string :record_type
      t.jsonb :data
      t.date :closing_date
      t.references :branch, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
    create_table :user_tasks, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :status
      t.string :task_type
      t.jsonb :data

      t.timestamps
    end
    add_column :users, :is_verified, :boolean
    add_column :users, :verification_token, :string
    create_table :branch_psr_records, id: :uuid do |t|
      t.references :branch, null: false, foreign_key: true, type: :uuid
      t.date :closing_date
      t.integer :closing_year
      t.integer :closing_month
      t.jsonb :data
      t.string :status

      t.timestamps
    end






  end #end to hindi pwede alisin














  def up
    unless column_exists?(:active_storage_blobs, :service_name)
      add_column :active_storage_blobs, :service_name, :string

      if configured_service = ActiveStorage::Blob.service.name
        ActiveStorage::Blob.unscoped.update_all(service_name: configured_service)
      end

      change_column :active_storage_blobs, :service_name, :string, null: false
    end
  end

  def down
    remove_column :active_storage_blobs, :service_name
  end
end
