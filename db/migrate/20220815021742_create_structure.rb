class CreateStructure < ActiveRecord::Migration[7.0]
  
  def change
    enable_extension 'pg_stat_statements'
  end

  def change
    enable_extension 'pgcrypto'
  end

  def change
    enable_extension 'plpgsql'
  end
  
  def change
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
  end

  def change
    create_table :account_transaction_collections, id: :uuid do |t|
      t.string :or_number
      t.decimal :total_amount
      t.references :center_id, null: false, foreign_key: true, type: :uuid
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.string :status
      t.datetime :transacted_at, precision: nil
      t.string :collection_type
      t.json :data
      
      t.timestamps
    end
  end

  def change

    create_table :account_transactions, id: :uuid do |t|
      t.references :subsidiary_id, null: false, foreign_key: true, type: :uuid
      t.string :subsidiary_type
      t.decimal :amount
      t.string :transaction_type
      t.datetime :transacted_at
      t.string :status
      t.json :data
      
      t.timestamps
    end
  end

  def change
    create_table :accounting_code_balances, id: :uuid do |t|
      t.references :accounting_code_id, null: false, foreign_key: true, type: :uuid
      t.references :accounting_fund_id, null: false, foreign_key: true, type: :uuid
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.string :category
      t.date :start_date
      t.date :end_date
      t.decimal :total_beginning_debit
      t.decimal :total_beginning_credit
      t.decimal :total_current_debit
      t.decimal :total_current_credit
      t.decimal :total_ending_debit
      t.decimal :total_ending_credit
      t.string :status

      t.timestamps
    end
  end

  def change
    create_table :accounting_entries, id: :uuid do |t|
      t.date :date_prepared
      t.date :date_posted
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.string :book
      t.string :reference_number
      t.string :particular
      t.string :approved_by
      t.string :prepared_by
      t.string :status
      t.json :data
      t.references :accounting_fund_id, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end

  def change
    create_table :accounting_funds, id: :uuid do |t|
      t.string :name
      
      t.timestamps
    end
  end

  def change
    create_table :accrued_billings, id: :uuid do |t|
      t.date :collection_date
      t.json :data
      t.string :status
      t.date :date_approved
      t.references :center_id, null: false, foreign_key: true, type: :uuid
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.string :member_id

      t.timestamps
    end
  end

  def change
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
      t.json :data
      t.string :number_of_moratoium_day
    end
  end

  def change
    create_table :active_storage_attachments do |t|
      t.string :name
      t.string :record_type
      t.bigint :blob_id
      t.datetime :created_at
      t.references :record_id
    end
  end

  def change
    create_table :active_storage_blobs do |t|
      t.string :key
      t.string :filename
      t.string :content_type
      t.text :metadata
      t.bigint :byte_size
      t.string :checksum
      t.datetime :created_at
      t.string :service_name
    end
  end
  
  def change
    create_table :active_storage_variant_records do |t|
      t.bigint :blob_id
      t.string :variation_digest
    end
  end

  def change
    create_table :activity_logs, id: :uuid do |t|
      t.string :content
      t.string :activity_type
      t.json :data
      
      t.timestamps
    end
  end

  def change
    create_table :adjustment_records, id: :uuid do |t|
      t.jsonb :meta
      t.jsonb :data
      t.string :status
      t.string :adjustment_type
      t.date :date_approved
      t.string :approved_by

      t.timestamps
    end
  end

  def change
    create_table :administration_branch_closing_records, id: :uuid do |t|
      t.references :data_store_id, null: false, foreign_key: true, type: :uuid
      t.string :record_type
      t.jsonb :data
      t.date :closing_date
      t.references :branch_id, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end

  def change

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
      t.references :loan_id, null: false, foreign_key: true, type: :uuid
      t.json :data
      
      t.timestamps
    end
  end

  def change
    create_table :announcements, id: :uuid do |t|
      t.string :title
      t.text :content
      t.references :user_id, null: false, foreign_key: true, type: :uuid
      t.string :status
      t.boolean :is_published
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.date :announced_at
      t.date :published_at

      t.timestamps
    end
  end

  def change
    create_table :areas, id: :uuid do |t|
      t.string :name
      t.string :short_name
      
      t.timestamps
    end
  end

  def change
    create_table :attachment_files, id: :uuid do |t|
      t.references :member_id, null: false, foreign_key: true, type: :uuid
      t.string :file_name
      t.jsonb :data
      
      t.timestamps
    end
  end

  def change
    create_table :beneficiaries, id: :uuid do |t|
      t.references :member_id, null: false, foreign_key: true, type: :uuid
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :relationship
      t.date :date_of_birth
      t.boolean :is_primary
      t.boolean :is_deceased
      
      t.timestamps
    end
  end

  def change
    create_table :billings, id: :uuid do |t|
      t.date :collection_date
      t.references :center_id, null: false, foreign_key: true, type: :uuid
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.jsonb :data
      t.string :status
      t.date :date_approved
      t.string :or_number
      t.string :ar_number
      t.decimal :total_collected
      t.decimal :total_expected_collections

      t.timestamps
    end
  end

  def change
    create_table :branch_psr_records, id: :uuid do |t|
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.date :closing_date
      t.integer :closing_year
      t.integer :closing_month
      t.jsonb :data
      t.string :status
      
      t.timestamps
    end
  end

  def change
    create_table :branches, id: :uuid do |t|
      t.references :cluster_id, null: false, foreign_key: true, type: :uuid
      t.string :name
      t.string :short_name
      t.integer :member_counter
      t.date :current_date
      t.string :color
      t.boolean :is_main
      t.string :or_prefix
      t.integer :or_counter
      t.integer :or_current_max
      t.string :ar_prefix
      t.integer :ar_counter
      t.integer :ar_current_max

      t.timestamps
    end
  end

  def change
    create_table :calamity_claims, id: :uuid do |t|
      t.references :member_id, null: false, foreign_key: true, type: :uuid
      t.references :center_id, null: false, foreign_key: true, type: :uuid
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.date :date_requested
      t.string :purpose
      t.string :type_of_calamity
      t.string :amount
      t.date :date_of_event
      t.date :date_approved
      t.date :date_of_notification
      t.string :name_of_payee
      t.string :name_of_beneficiary
      t.string :prepared_by
      t.string :claim_type
      t.json :data

      t.timestamps
    end
  end

  def change
    create_table :centers, id: :uuid do |t|
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.string :name
      t.string :short_name
      t.integer :meeting_day
      t.references :user_id, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end

  def change
    create_table :claim_attachment_files, id: :uuid do |t|
      t.references :claim_id, null: false, foreign_key: true, type: :uuid
      t.string :file_name
      t.jsonb :data
      
      t.timestamps
    end
  end


  def change

    create_table :claims, id: :uuid do |t|
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
      t.references :member_id
      t.references :center_id
      t.references :branch_id
      t.string :claim_type
      t.json :data
      t.string :status
      t.string :approved_by
      t.string :checked_by
      t.date :date_checked
      t.date :date_approved
      t.string :posted_by
      t.date :date_posted

      t.timestamps
    end
  end

  def change
    create_table :clip_claims, id: :uuid do |t|
      t.references :member_id, null: false, foreign_key: true, type: :uuid
      t.references :center_id, null: false, foreign_key: true, type: :uuid
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
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
      t.string :claim_type
      t.json :data

      t.timestamps
    end
  end

  def change
    create_table :clusters, id: :uuid do |t|
      t.references :area_id, null: false, foreign_key: true, type: :uuid
      t.string :name
      t.string :short_name
      
      t.timestamps
    end
  end


  def change
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
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.references :cluster_id, null: false, foreign_key: true, type: :uuid
      t.references :area_id, null: false, foreign_key: true, type: :uuid
      
      t.timestamps
    end
  end

  def change

    create_table :data_stores, id: :uuid do |t|
      t.json :meta
      t.json :data
      t.string :status
      t.date :as_of
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end


  def change
    create_table :deposit_collections, id: :uuid do |t|
      t.date :collection_date
      t.references :center_id, null: false, foreign_key: true, type: :uuid
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.jsonb :data
      t.string :status
      t.date :date_approved
      t.timestamps
    end
  end

  def change
    create_table :dw_branch_active_loan_counts, id: :uuid do |t|
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.references :cluster_id, null: false, foreign_key: true, type: :uuid
      t.references :area_id, null: false, foreign_key: true, type: :uuid
      t.string :status
      t.date :as_of
      t.jsonb :data
      t.integer :total
      t.integer :month
      t.integer :year

      t.timestamps
    end
  end


  def change
    create_table :dw_branch_loan_past_dues, id: :uuid do |t|
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.references :area_id, null: false, foreign_key: true, type: :uuid
      t.references :cluster_id, null: false, foreign_key: true, type: :uuid
      t.decimal :amount
      t.jsonb :data
      t.string :record_type
      t.string :status
      t.integer :month
      t.integer :year
      
      t.timestamps
    end
  end

  def change
    create_table :dw_branch_loan_product_active_loan_counts, id: :uuid do |t|
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.references :cluster_id, null: false, foreign_key: true, type: :uuid
      t.references :area_id, null: false, foreign_key: true, type: :uuid
      t.string :status
      t.date :as_of
      t.jsonb :data
      t.integer :total
      t.references :loan_product_id, null: false, foreign_key: true, type: :uuid
      t.references :loan_product_category_id, null: false, foreign_key: true, type: :uuid
      t.integer :month
      t.integer :year
      
      t.timestamps
    end
  end

  def change
    create_table :dw_branch_loan_product_outstanding_loan_amounts, id: :uuid do |t|
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.references :cluster_id, null: false, foreign_key: true, type: :uuid
      t.references :area_id, null: false, foreign_key: true, type: :uuid
      t.string :status
      t.jsonb :data
      t.decimal :amount
      t.references :loan_product_category_id, null: false, foreign_key: true, type: :uuid
      t.references :loan_product_id, null: false, foreign_key: true, type: :uuid
      t.date :as_of
      
      t.timestamps
    end
  end

  def change
    create_table :dw_branch_member_counts, id: :uuid do |t|
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.references :cluster_id, null: false, foreign_key: true, type: :uuid
      t.references :area_id, null: false, foreign_key: true, type: :uuid
      t.string :status
      t.date :as_of
      t.jsonb :data
      t.integer :count_male
      t.integer :count_female
      t.integer :total
      t.string :record_type
      t.integer :count_others
      t.integer :month
      t.integer :year

      t.timestamps
    end
  end

  def change
    create_table :dw_branch_monthly_loan_amount_collections, id: :uuid do |t|
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.references :area_id, null: false, foreign_key: true, type: :uuid
      t.references :cluster_id, null: false, foreign_key: true, type: :uuid
      t.decimal :amount
      t.jsonb :data
      t.string :status
      t.integer :month
      t.integer :year
      t.timestamps
    end
  end

  def change
    create_table :dw_branch_monthly_loan_amount_dues, id: :uuid do |t|
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.references :area_id, null: false, foreign_key: true, type: :uuid
      t.references :cluster_id, null: false, foreign_key: true, type: :uuid
      t.decimal :amount
      t.jsonb :data
      t.string :status
      t.integer :month
      t.integer :year

      t.timestamps

    end
  end

  def change
    create_table :dw_branch_monthly_loan_product_disbursed_counts, id: :uuid do |t|
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.references :area_id, null: false, foreign_key: true, type: :uuid
      t.references :cluster_id, null: false, foreign_key: true, type: :uuid
      t.references :loan_product_id, null: false, foreign_key: true, type: :uuid
      t.references :loan_product_category_id, null: false, foreign_key: true, type: :uuid
      t.integer :month
      t.integer :year
      t.string :status
      t.integer :total
      t.jsonb :data
      t.decimal :amount

      t.timestamps
    end
  end

  def change
    create_table :dw_branch_new_member_counts, id: :uuid do |t|
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.references :cluster_id, null: false, foreign_key: true, type: :uuid
      t.references :area_id, null: false, foreign_key: true, type: :uuid
      t.string :status
      t.jsonb :data
      t.integer :total
      t.integer :month
      t.integer :year

      t.timestamps
    end
  end

  def change
    create_table :dw_branch_par_amounts, id: :uuid do |t|
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.references :area_id, null: false, foreign_key: true, type: :uuid
      t.references :cluster_id, null: false, foreign_key: true, type: :uuid
      t.decimal :amount
      t.jsonb :data
      t.string :record_type
      t.string :status
      t.integer :month
      t.integer :year
      
      t.timestamps
    end
  end

  def change
    create_table :dw_branch_resigned_member_counts, id: :uuid do |t|
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.references :cluster_id, null: false, foreign_key: true, type: :uuid
      t.references :area_id, null: false, foreign_key: true, type: :uuid
      t.integer :total
      t.integer :month
      t.integer :year
      
      t.timestamps
    end
  end


  def change
    create_table :equity_withdrawal_collections, id: :uuid do |t|
      t.date :collection_date
      t.references :center_id, null: false, foreign_key: true, type: :uuid
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.jsonb :data
      t.string :status
      t.date :date_approved
      
      t.timestamps
    end
  end

  def change
    create_table :file_repositories, id: :uuid do |t|
      t.string :file_type
      
      t.timestamps
    end
  end


  def change
    create_table :hiip_claims, id: :uuid do |t|
      t.references :member_id, null: false, foreign_key: true, type: :uuid
      t.references :center_id, null: false, foreign_key: true, type: :uuid
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.date :date_posted
      t.decimal :amount
      t.text :mode_of_payment
      t.string :policy_number
      t.date :effective_date_of_coverage
      t.date :expiration_date_of_coverage
      t.date :date_admitted
      t.date :date_discharged
      t.string :number_ofdays_tobepaid
      t.date :date_of_birth
      t.string :age
      t.text :reason_of_confinement
      t.text :diagnosis
      t.string :check_payee
      t.string :prepared_by
      t.decimal :balance
      t.string :claim_type
      t.json :data
      t.date :date_prepared

      t.timestamps
    end
  end

  def change
    create_table :insurance_fund_transfer_collections, id: :uuid do |t|
      t.date :collection_date
      t.references :center_id, null: false, foreign_key: true, type: :uuid
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.jsonb :data
      t.string :status
      t.date :date_approved

      t.timestamps
    end
  end

  def change
    create_table :insurance_monthly_closing_collections, id: :uuid do |t|
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.date :closing_date
      t.date :closed_at
      t.jsonb :data
      t.jsonb :meta
      t.string :status
      t.string :account_subtype
      t.timestamps
    end
  end

  def change
    create_table :insurance_withdrawal_collections, id: :uuid do |t|
      t.date :collection_date
      t.references :center_id, null: false, foreign_key: true, type: :uuid
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.jsonb :data
      t.string :status
      t.date :date_approved
      t.timestamps
    end
  end


  def change
    create_table :interests, id: :uuid do |t|
      t.references :member_account_id, null: false, foreign_key: true, type: :uuid
      t.references :account_transaction_id, null: false, foreign_key: true, type: :uuid
      t.date :month_of_year_date
      t.decimal :interest_amount
      t.timestamps
      t.string :interest_type
    end
  end

  def change
    create_table :journal_entries, id: :uuid do |t|
      t.string :post_type
      t.references :accounting_code_id, null: false, foreign_key: true, type: :uuid
      t.references :accounting_entry_id, null: false, foreign_key: true, type: :uuid
      t.json :data
      t.decimal :amount
      t.timestamps
      t.string :book
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.references :accounting_fund_id, null: false, foreign_key: true, type: :uuid
      t.string :status
      t.date :date_prepared
      t.date :ae_date_posted
    end
  end

  def change
    create_table :kalinga_claims, id: :uuid do |t|
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
      t.string :insured_address
      t.string :civil_status
      t.date :date_of_birth
      t.string :name_of_beneficiary
      t.date :date_of_death_or_incident
      t.text :reason_of_death
      t.string :gender
      t.string :prepared_by
      t.timestamps
      t.date :issueddate
      t.string :claim_type
      t.json :data
      t.references :member_id, null: false, foreign_key: true, type: :uuid
      t.references :center_id, null: false, foreign_key: true, type: :uuid
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
    end
  end

  def change
    create_table :kbente_claims, id: :uuid do |t|
      t.references :member_id, null: false, foreign_key: true, type: :uuid
      t.references :center_id, null: false, foreign_key: true, type: :uuid
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
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
      t.string :claim_type
      t.json :data
    end
  end

  
  def change
    create_table :kjsp_claims, id: :uuid do |t|
      t.references :member_id, null: false, foreign_key: true, type: :uuid
      t.references :center_id, null: false, foreign_key: true, type: :uuid
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
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
      t.string :classification
      t.string :received_by
      t.string :prepared_by
      t.string :course
      t.string :claim_type
      t.json :data
    end
  end

  def change
    create_table :legal_dependents, id: :uuid do |t|
      t.string :first_name
      t.string :middle_name
      t.date :date_of_birth
      t.references :member_id, null: false, foreign_key: true, type: :uuid
      t.string :relationship
      t.json :data
      t.timestamps
      t.string :last_name
    end
  end


  def change
    create_table :loan_product_categories, id: :uuid do |t|
      t.string :name
      t.string :code
      t.timestamps
    end
  end

  def change
    create_table :loan_products, id: :uuid do |t|
      t.string :name
      t.decimal :max_loan_amount
      t.decimal :min_loan_amount
      t.decimal :denomination
      t.boolean :insured
      t.boolean :is_entry_point
      t.decimal :monthly_interest_rate
      t.timestamps
      t.json :data
      t.integer :priority
      t.references :loan_product_category_id, null: false, foreign_key: true, type: :uuid
    end
  end

  def change
    create_table :loan_repayment_rates, id: :uuid do |t|
      t.references :loan_id, null: false, foreign_key: true, type: :uuid
      t.date :as_of
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.references :center_id, null: false, foreign_key: true, type: :uuid
      t.jsonb :data
      t.timestamps
    end
  end

  def change
    create_table :loans, id: :uuid do |t|
      t.references :center_id, null: false, foreign_key: true, type: :uuid
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.date :date_prepared
      t.date :date_approved
      t.date :date_released
      t.date :date_completed
      t.references :member_id, null: false, foreign_key: true, type: :uuid
      t.decimal :principal
      t.decimal :interest
      t.decimal :principal_paid
      t.decimal :principal_balance
      t.decimal :interest_paid
      t.decimal :interest_balance
      t.string :status
      t.references :loan_product_id, null: false, foreign_key: true, type: :uuid
      t.string :term
      t.string :pn_number
      t.string :payment_type
      t.integer :num_installments
      t.decimal :monthly_interest_rate
      t.references :project_type_id, null: false, foreign_key: true, type: :uuid
      t.json :data
      t.timestamps
      t.date :first_date_of_payment
      t.integer :cycle
      t.date :maturity_date
      t.date :max_active_date
      t.references :user_id, null: false, foreign_key: true, type: :uuid
      t.date :original_maturity_date
      t.boolean :is_restructured
      t.references :loan_product_type_id, null: false, foreign_key: true, type: :uuid
    end
  end

  def change
    create_table :make_payments, id: :uuid do |t|
      t.references :member_id, null: false, foreign_key: true, type: :uuid
      t.date :transaction_date
      t.date :date_approve
      t.string :approved_by
      t.string :created_by
      t.json :data
      t.string :status
      t.timestamps
      t.string :make_payment_type
      t.json :meta
    end
  end

  def change
    create_table :member_account_daily_statements, id: :uuid do |t|
      t.references :member_id, null: false, foreign_key: true, type: :uuid
      t.references :member_account_id, null: false, foreign_key: true, type: :uuid
      t.date :transacted_at
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.decimal :debit_amount
      t.decimal :credit_amount
      t.timestamps
    end
  end


  def change
    create_table :member_account_validation_cancellations, id: :uuid do |t|
      t.references :member_account_validation_id, null: false, foreign_key: true, type: :uuid
      t.references :member_id, null: false, foreign_key: true, type: :uuid
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.text :reason
      t.date :date_cancelled
      t.timestamps
    end
  end

  def change
    create_table :member_account_validation_records, id: :uuid do |t|
      t.references :member_account_validation_id, null: false, foreign_key: true, type: :uuid
      t.references :member_id, null: false, foreign_key: true, type: :uuid
      t.references :center_id, null: false, foreign_key: true, type: :uuid
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
      t.decimal :advance_lif
      t.json :data
      t.decimal :equity_value
      t.decimal :policy_loan
    end
  end


  def change
    create_table :member_account_validations, id: :uuid do |t|
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
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
      t.json :data
      t.decimal :total_policy_loan
    
    end
  end

  def change
    create_table :member_accounts, id: :uuid do |t|
      t.references :member_id, null: false, foreign_key: true, type: :uuid
      t.string :account_type
      t.string :account_subtype
      t.decimal :balance
      t.references :center_id, null: false, foreign_key: true, type: :uuid
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.string :status
      t.decimal :maintaining_balance
      t.timestamps
      t.json :data
    end
  end


  def change
    create_table :member_loan_moratoria, id: :uuid do |t|
      t.references :member_moratorium_id, null: false, foreign_key: true, type: :uuid
      t.references :loan_id, null: false, foreign_key: true, type: :uuid
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.references :center_id, null: false, foreign_key: true, type: :uuid
      t.references :member_id, null: false, foreign_key: true, type: :uuid
      t.date :date_initialized
      t.string :status
      t.jsonb :data
      t.timestamps
      t.integer :number_of_days
      t.string :reason
    end
  end

  def change
    create_table :member_moratoria, id: :uuid do |t|
      t.string :status
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.references :center_id, null: false, foreign_key: true, type: :uuid
      t.references :member_id, null: false, foreign_key: true, type: :uuid
      t.date :date_initialized
      t.jsonb :data
      t.timestamps
      t.integer :number_of_days
      t.string :reason
    end
  end


  def change
    create_table :member_shares, id: :uuid do |t|
      t.references :member_id, null: false, foreign_key: true, type: :uuid
      t.string :certificate_number
      t.jsonb :data
      t.timestamps
      t.date :date_of_issue
      t.boolean :is_void
      t.integer :number_of_shares
      t.string :certificate_for
    end
  end

  def change
    create_table :members, id: :uuid do |t|
      t.references :center_id, null: false, foreign_key: true, type: :uuid
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
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
      t.string :access_token
      t.text :signature_data
      t.boolean :modifiable
      t.date :previous_date_resigned
      t.date :insurance_date_resigned
      t.references :member_id, null: false, foreign_key: true, type: :uuid
      t.string :encrypted_password
      t.string :username
      t.references :online_application_id
      t.references :membership_arrangement_id, null: false, foreign_key: true, type: :uuid
      t.references :membership_type_id, null: false, foreign_key: true, type: :uuid
      t.references :referrer_id, null: false, foreign_key: true, type: :uuid
      t.references :coordinator_id, null: false, foreign_key: true, type: :uuid
      t.string :email
    end
  end

  def change
    create_table :membership_arrangements, id: :uuid do |t|
      t.string :name
      t.jsonb :data
      t.timestamps
    end
  end

  def change
    create_table :membership_types, id: :uuid do |t|
      t.string :name
      t.json :data
      t.timestamps
    end
  end


  def change
    create_table :monthly_accounting_code_summaries, id: :uuid do |t|
      t.integer :month
      t.integer :year
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.references :accounting_code_id, null: false, foreign_key: true, type: :uuid
      t.string :category
      t.string :name
      t.decimal :dr_amount
      t.decimal :cr_amount
      t.timestamps
    end
  end

  def change
    create_table :monthly_closing_collections, id: :uuid do |t|
      t.date :closing_date
      t.date :closed_at
      t.jsonb :data
      t.jsonb :meta
      t.timestamps
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.string :status
      t.string :account_subtype
    end
  end

  def change
    create_table :online_application_documents, id: :uuid do |t|
      t.string :file_name
      t.jsonb :data
      t.references :online_application_id, null: false, foreign_key: true, type: :uuid
      t.timestamps
    end
  end

  def change
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
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.boolean :agreed_to_dp_terms
      t.references :membership_type_id, null: false, foreign_key: true, type: :uuid
      t.references :membership_arrangement_id, null: false, foreign_key: true, type: :uuid
      t.references :center_id, null: false, foreign_key: true, type: :uuid
      t.string :email
    end
  end

  def change
    create_table :project_type_categories, id: :uuid do |t|
      t.string :name
      t.string :code
      t.timestamps
    end
  end

  def change
    create_table :project_types, id: :uuid do |t|
      t.string :name
      t.string :code
      t.references :project_type_category_id, null: false, foreign_key: true, type: :uuid
      t.timestamps
    end
  end

  def change
    create_table :recompute_restructures, id: :uuid do |t|
      t.string :branch, null: false, foreign_key: true, type: :uuid
      t.string :center, null: false, foreign_key: true, type: :uuid
      t.string :status
      t.date :transaction_date
      t.json :data
      t.timestamps
      t.string :member
      t.string :loan
    end
  end

  def change
    create_table :referrers, id: :uuid do |t|
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :status
      t.string :contact_number
      t.jsonb :data
      t.timestamps
      t.date :date_registered
      t.string :category
    end
  end

  def change
    create_table :savings_insurance_transfer_collections, id: :uuid do |t|
      t.string :status
      t.references :center_id, null: false, foreign_key: true, type: :uuid
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.date :collection_date
      t.date :date_approved
      t.jsonb :data
      t.timestamps
      t.decimal :total_amount
      t.string :approved_by
    end
  end


  def change
    create_table :structures, id: :uuid do |t|
      t.timestamps
    end
  end

  def change
    create_table :survey_answers, id: :uuid do |t|
      t.references :survey_id, null: false, foreign_key: true, type: :uuid
      t.jsonb :meta
      t.jsonb :data
      t.string :status
      t.timestamps
    end
  end

  def change
    create_table :survey_questions, id: :uuid do |t|
      t.references :survey_id, null: false, foreign_key: true, type: :uuid
      t.string :content
      t.string :question_type
      t.jsonb :data
      t.timestamps
      t.integer :priority
    end
  end

  def change
    create_table :surveys, id: :uuid do |t|
      t.string :name
      t.jsonb :data
      t.timestamps
      t.string :status
    end
  end

  def change
    create_table :time_deposit_collections, id: :uuid do |t|
      t.date :collection_date
      t.references :center_id, null: false, foreign_key: true, type: :uuid
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.jsonb :data
      t.string :status
      t.date :date_approved
      t.timestamps
    end
  end

  def change
    create_table :transfer_member_records, id: :uuid do |t|
      t.string :branch_id, null: false, foreign_key: true, type: :uuid
      t.date :transfer_date
      t.string :status
      t.date :date_approved
      t.json :data
      t.timestamps
      t.string :branch_id_to_transfer
    end
  end

  def change
    create_table :user_branches, id: :uuid do |t|
      t.references :user_id, null: false, foreign_key: true, type: :uuid
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
      t.boolean :active
      t.timestamps
    end
  end


  def change
    create_table :user_demerits, id: :uuid do |t|
      t.references :user_id, null: false, foreign_key: true, type: :uuid
      t.references :branch_id, null: false, foreign_key: true, type: :uuid
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
  end
  def change
    create_table :user_tasks, id: :uuid do |t|
      t.references :user_id, null: false, foreign_key: true, type: :uuid
      t.string :status
      t.string :task_type
      t.jsonb :data

      t.timestamps
    end
  end


  def change
    create_table :users, id: :uuid do |t|
      t.string :email
      t.string :encrypted_password
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.integer :sign_in_count
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet :current_sign_in_ip
      t.inet :last_sign_in_ip
      t.timestamps
      t.string :username
      t.string :first_name
      t.string :last_name
      t.string :identification_number
      t.string :roles
      t.boolean :is_regular
      t.date :incentivized_date
      t.string :access_token
      t.boolean :is_verified
      t.string :verification_token
    end
  end
  def change
    create_table :withdrawal_collections, id: :uuid do |t|
      t.date :collection_date
      t.references :center_id
      t.references :branch_id
      t.jsonb :data
      t.string :status
      t.timestamps
      t.date :date_approved
    end
  end
end
