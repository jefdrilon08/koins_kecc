# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_03_06_031352) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "account_transaction_collections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "or_number"
    t.decimal "total_amount"
    t.uuid "center_id"
    t.uuid "branch_id"
    t.string "status"
    t.datetime "transacted_at"
    t.string "collection_type"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_account_transaction_collections_on_branch_id"
    t.index ["center_id"], name: "index_account_transaction_collections_on_center_id"
  end

  create_table "account_transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "subsidiary_id"
    t.string "subsidiary_type"
    t.decimal "amount"
    t.string "transaction_type"
    t.datetime "transacted_at"
    t.string "status"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "accounting_codes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "category"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "accounting_entries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.date "date_prepared"
    t.date "date_posted"
    t.uuid "branch_id"
    t.string "book"
    t.string "reference_number"
    t.string "particular"
    t.string "approved_by"
    t.string "prepared_by"
    t.string "status"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "accounting_fund_id"
    t.index ["accounting_fund_id"], name: "index_accounting_entries_on_accounting_fund_id"
    t.index ["branch_id"], name: "index_accounting_entries_on_branch_id"
  end

  create_table "accounting_funds", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "activity_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "content"
    t.string "activity_type"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "amortization_schedule_entries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "amount_due"
    t.decimal "principal"
    t.decimal "interest"
    t.decimal "principal_paid"
    t.decimal "interest_paid"
    t.decimal "principal_balance"
    t.decimal "interest_balance"
    t.date "due_date"
    t.boolean "is_paid"
    t.uuid "loan_id"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["loan_id"], name: "index_amortization_schedule_entries_on_loan_id"
  end

  create_table "announcements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id"
  end

  create_table "areas", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "short_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "beneficiaries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "member_id"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "relationship"
    t.date "date_of_birth"
    t.boolean "is_primary"
    t.boolean "is_deceased"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_beneficiaries_on_member_id"
  end

  create_table "billings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.date "collection_date"
    t.uuid "center_id"
    t.uuid "branch_id"
    t.jsonb "data"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date_approved"
    t.index ["branch_id"], name: "index_billings_on_branch_id"
    t.index ["center_id"], name: "index_billings_on_center_id"
  end

  create_table "branches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "cluster_id"
    t.string "name"
    t.string "short_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "member_counter"
    t.index ["cluster_id"], name: "index_branches_on_cluster_id"
  end

  create_table "centers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "branch_id"
    t.string "name"
    t.string "short_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "meeting_day"
    t.uuid "user_id"
    t.index ["branch_id"], name: "index_centers_on_branch_id"
  end

  create_table "claims", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "member_id"
    t.integer "center_id"
    t.integer "branch_id"
    t.date "date_prepared"
    t.string "policy_number"
    t.string "type_of_insurance_policy"
    t.string "name_of_insured"
    t.string "beneficiary"
    t.string "classification_of_insured"
    t.date "date_of_birth"
    t.string "gender"
    t.date "date_of_policy_issue"
    t.decimal "face_amount"
    t.date "date_of_death_tpd_accident"
    t.decimal "arrears"
    t.text "cause_of_death_tpd_accident"
    t.decimal "amount_benefit_payable"
    t.decimal "equity_value"
    t.decimal "retirement_fund"
    t.string "prepared_by"
    t.string "length_of_stay"
    t.decimal "returned_contribution"
    t.decimal "total_amount_payable"
    t.string "order_of_child"
    t.string "category_of_cause_of_death_tpd_accident"
    t.date "date_reported"
    t.date "date_paid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "clusters", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "area_id"
    t.string "name"
    t.string "short_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id"], name: "index_clusters_on_area_id"
  end

  create_table "data_stores", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.json "meta"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
  end

  create_table "deposit_collections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.date "collection_date"
    t.uuid "center_id"
    t.uuid "branch_id"
    t.jsonb "data"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date_approved"
    t.index ["branch_id"], name: "index_deposit_collections_on_branch_id"
    t.index ["center_id"], name: "index_deposit_collections_on_center_id"
  end

  create_table "journal_entries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "post_type"
    t.uuid "accounting_code_id"
    t.uuid "accounting_entry_id"
    t.json "data"
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["accounting_code_id"], name: "index_journal_entries_on_accounting_code_id"
    t.index ["accounting_entry_id"], name: "index_journal_entries_on_accounting_entry_id"
  end

  create_table "legal_dependents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name"
    t.string "middle_name"
    t.date "date_of_birth"
    t.uuid "member_id"
    t.string "relationship"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "last_name"
    t.index ["member_id"], name: "index_legal_dependents_on_member_id"
  end

  create_table "loan_products", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.decimal "max_loan_amount"
    t.decimal "min_loan_amount"
    t.decimal "denomination"
    t.boolean "insured"
    t.boolean "is_entry_point"
    t.decimal "monthly_interest_rate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "data"
    t.integer "priority"
  end

  create_table "loans", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "center_id"
    t.uuid "branch_id"
    t.date "date_prepared"
    t.date "date_approved"
    t.date "date_released"
    t.date "date_completed"
    t.uuid "member_id"
    t.decimal "principal"
    t.decimal "interest"
    t.decimal "principal_paid"
    t.decimal "principal_balance"
    t.decimal "interest_paid"
    t.decimal "interest_balance"
    t.string "status"
    t.uuid "loan_product_id"
    t.string "term"
    t.string "pn_number"
    t.string "payment_type"
    t.integer "num_installments"
    t.decimal "monthly_interest_rate"
    t.uuid "project_type_id"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "first_date_of_payment"
    t.integer "cycle"
    t.index ["branch_id"], name: "index_loans_on_branch_id"
    t.index ["center_id"], name: "index_loans_on_center_id"
    t.index ["loan_product_id"], name: "index_loans_on_loan_product_id"
    t.index ["member_id"], name: "index_loans_on_member_id"
    t.index ["project_type_id"], name: "index_loans_on_project_type_id"
  end

  create_table "member_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "member_id"
    t.string "account_type"
    t.string "account_subtype"
    t.decimal "balance"
    t.uuid "center_id"
    t.uuid "branch_id"
    t.string "status"
    t.decimal "maintaining_balance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "data"
    t.index ["branch_id"], name: "index_member_accounts_on_branch_id"
    t.index ["center_id"], name: "index_member_accounts_on_center_id"
    t.index ["member_id"], name: "index_member_accounts_on_member_id"
  end

  create_table "member_shares", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "member_id"
    t.string "certificate_number"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date_of_issue"
    t.index ["member_id"], name: "index_member_shares_on_member_id"
  end

  create_table "members", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "center_id"
    t.uuid "branch_id"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "gender"
    t.date "date_of_birth"
    t.string "civil_status"
    t.string "home_number"
    t.string "mobile_number"
    t.string "processed_by"
    t.string "approved_by"
    t.string "identification_number"
    t.string "place_of_birth"
    t.string "status"
    t.string "member_type"
    t.string "religion"
    t.string "insurance_status"
    t.json "data"
    t.date "date_resigned"
    t.json "meta"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "access_token"
    t.text "signature_data"
    t.boolean "modifiable"
    t.index ["branch_id"], name: "index_members_on_branch_id"
    t.index ["center_id"], name: "index_members_on_center_id"
  end

  create_table "membership_payment_collections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.date "collection_date"
    t.uuid "center_id"
    t.uuid "branch_id"
    t.jsonb "data"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date_approved"
    t.index ["branch_id"], name: "index_membership_payment_collections_on_branch_id"
    t.index ["center_id"], name: "index_membership_payment_collections_on_center_id"
  end

  create_table "membership_payment_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "membership_type"
    t.string "membership_name"
    t.decimal "amount"
    t.date "date_paid"
    t.string "status"
    t.uuid "member_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date_voided"
    t.index ["member_id"], name: "index_membership_payment_records_on_member_id"
  end

  create_table "monthly_closing_collections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.date "closing_date"
    t.date "closed_at"
    t.jsonb "data"
    t.jsonb "meta"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "branch_id"
    t.string "status"
    t.string "account_subtype"
    t.index ["branch_id"], name: "index_monthly_closing_collections_on_branch_id"
  end

  create_table "project_type_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "project_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.uuid "project_type_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_type_category_id"], name: "index_project_types_on_project_type_category_id"
  end

  create_table "survey_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "survey_id"
    t.jsonb "meta"
    t.jsonb "data"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_id"], name: "index_survey_answers_on_survey_id"
  end

  create_table "survey_questions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "survey_id"
    t.string "content"
    t.string "question_type"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "priority"
    t.index ["survey_id"], name: "index_survey_questions_on_survey_id"
  end

  create_table "surveys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
  end

  create_table "user_branches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.uuid "branch_id"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.string "first_name"
    t.string "last_name"
    t.string "identification_number"
    t.string "roles"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "withdrawal_collections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.date "collection_date"
    t.uuid "center_id"
    t.uuid "branch_id"
    t.jsonb "data"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date_approved"
    t.index ["branch_id"], name: "index_withdrawal_collections_on_branch_id"
    t.index ["center_id"], name: "index_withdrawal_collections_on_center_id"
  end

  add_foreign_key "account_transaction_collections", "branches"
  add_foreign_key "account_transaction_collections", "centers"
  add_foreign_key "accounting_entries", "accounting_funds"
  add_foreign_key "accounting_entries", "branches"
  add_foreign_key "amortization_schedule_entries", "loans"
  add_foreign_key "beneficiaries", "members"
  add_foreign_key "billings", "branches"
  add_foreign_key "billings", "centers"
  add_foreign_key "branches", "clusters"
  add_foreign_key "centers", "branches"
  add_foreign_key "clusters", "areas"
  add_foreign_key "deposit_collections", "branches"
  add_foreign_key "deposit_collections", "centers"
  add_foreign_key "journal_entries", "accounting_codes"
  add_foreign_key "journal_entries", "accounting_entries"
  add_foreign_key "legal_dependents", "members"
  add_foreign_key "loans", "branches"
  add_foreign_key "loans", "centers"
  add_foreign_key "loans", "loan_products"
  add_foreign_key "loans", "members"
  add_foreign_key "loans", "project_types"
  add_foreign_key "member_accounts", "branches"
  add_foreign_key "member_accounts", "centers"
  add_foreign_key "member_accounts", "members"
  add_foreign_key "member_shares", "members"
  add_foreign_key "members", "branches"
  add_foreign_key "members", "centers"
  add_foreign_key "membership_payment_collections", "branches"
  add_foreign_key "membership_payment_collections", "centers"
  add_foreign_key "membership_payment_records", "members"
  add_foreign_key "monthly_closing_collections", "branches"
  add_foreign_key "project_types", "project_type_categories"
  add_foreign_key "survey_answers", "surveys"
  add_foreign_key "survey_questions", "surveys"
  add_foreign_key "withdrawal_collections", "branches"
  add_foreign_key "withdrawal_collections", "centers"
end
