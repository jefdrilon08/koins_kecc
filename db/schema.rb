# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_11_05_052214) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "account_transaction_collections", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "or_number"
    t.decimal "total_amount"
    t.uuid "center_id"
    t.uuid "branch_id"
    t.string "status"
    t.datetime "transacted_at", precision: nil
    t.string "collection_type"
    t.json "data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["branch_id"], name: "index_account_transaction_collections_on_branch_id"
    t.index ["center_id"], name: "index_account_transaction_collections_on_center_id"
  end

  create_table "account_transactions", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "subsidiary_id"
    t.string "subsidiary_type"
    t.decimal "amount"
    t.string "transaction_type"
    t.datetime "transacted_at", precision: nil
    t.string "status"
    t.json "data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "external_ref"
    t.index ["subsidiary_id", "transacted_at"], name: "idx_compute_interest1", where: "(((transaction_type)::text = ANY (ARRAY[('deposit'::character varying)::text, ('withdraw'::character varying)::text])) AND (NOT ((data ->> 'is_interest'::text) = 'true'::text)))"
    t.index ["subsidiary_id", "transacted_at"], name: "manual_idx_1", where: "((transaction_type)::text = ANY (ARRAY[('deposit'::character varying)::text, ('withdraw'::character varying)::text]))"
    t.index ["subsidiary_id", "transacted_at"], name: "manual_idx_14"
    t.index ["subsidiary_id", "transaction_type", "transacted_at"], name: "idx_account_transactions_soa_personal_funds", where: "(amount > (0)::numeric)"
    t.index ["transacted_at", "subsidiary_id"], name: "index_account_transactions_loan_payments", where: "(((transaction_type)::text = 'loan_payment'::text) AND ((subsidiary_type)::text = 'Loan'::text) AND (amount > (0)::numeric))"
    t.index ["transacted_at"], name: "index_account_transactions_on_transacted_at"
    t.index ["transaction_type"], name: "index_account_transactions_on_transaction_type"
  end

  create_table "accounting_code_balances", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "accounting_code_id", null: false
    t.uuid "accounting_fund_id"
    t.uuid "branch_id", null: false
    t.string "category"
    t.date "start_date"
    t.date "end_date"
    t.decimal "total_beginning_debit"
    t.decimal "total_beginning_credit"
    t.decimal "total_current_debit"
    t.decimal "total_current_credit"
    t.decimal "total_ending_debit"
    t.decimal "total_ending_credit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.index ["accounting_code_id", "category", "branch_id", "start_date", "end_date"], name: "idx_acb_ac_id_cat_branch_id_sd_ed"
    t.index ["accounting_code_id"], name: "index_accounting_code_balances_on_accounting_code_id"
    t.index ["accounting_fund_id"], name: "index_accounting_code_balances_on_accounting_fund_id"
    t.index ["branch_id"], name: "index_accounting_code_balances_on_branch_id"
  end

  create_table "accounting_codes", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "category"
    t.json "data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["category"], name: "manual_idx_19"
  end

  create_table "accounting_entries", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.uuid "accounting_fund_id"
    t.index ["accounting_fund_id"], name: "index_accounting_entries_on_accounting_fund_id"
    t.index ["book", "reference_number", "particular"], name: "manual_idx_9"
    t.index ["branch_id", "date_posted"], name: "manual_idx_17", where: "((status)::text = 'approved'::text)"
    t.index ["branch_id"], name: "index_accounting_entries_on_branch_id"
    t.index ["date_prepared"], name: "manual_idx_16"
  end

  create_table "accounting_funds", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "accrued_billings", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.date "collection_date"
    t.json "data"
    t.string "status"
    t.date "date_approved"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "center_id"
    t.uuid "branch_id"
    t.string "member_id"
    t.index ["branch_id"], name: "index_accrued_billings_on_branch_id"
    t.index ["center_id"], name: "index_accrued_billings_on_center_id"
  end

  create_table "accrued_interests", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "branch"
    t.string "center"
    t.string "member"
    t.date "cut_off_date"
    t.date "start_date"
    t.date "end_date"
    t.string "number_of_days"
    t.string "accrued_type"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "data"
    t.string "number_of_moratoium_day"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.uuid "record_id"
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activity_logs", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "content"
    t.string "activity_type"
    t.json "data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index "((data ->> 'billing_id'::text)), created_at DESC", name: "manual_idx_13"
    t.index "((data ->> 'loan_id'::text)), created_at DESC", name: "manual_idx_8"
    t.index "((data ->> 'member_id'::text)), created_at DESC", name: "manual_idx_15"
    t.index ["created_at"], name: "manual_idx_4", order: :desc
  end

  create_table "addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "region_name"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "adjustment_records", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "meta"
    t.jsonb "data"
    t.string "status"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "adjustment_type"
    t.date "date_approved"
    t.string "approved_by"
  end

  create_table "admin_addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "region_name"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_active"
    t.string "province_name"
  end

  create_table "admin_barangays", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "barangay_name"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "municipality_id"
  end

  create_table "admin_municipalities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "municipality_name"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "province_id"
  end

  create_table "admin_provinces", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "province_name"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "region_id"
  end

  create_table "administration_addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "region_name"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "administration_branch_closing_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "data_store_id", null: false
    t.string "record_type"
    t.jsonb "data"
    t.date "closing_date"
    t.uuid "branch_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_administration_branch_closing_records_on_branch_id"
    t.index ["data_store_id"], name: "index_administration_branch_closing_records_on_data_store_id"
  end

  create_table "amortization_schedule_entries", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["loan_id", "due_date"], name: "idx_amortization_schedule_entries_loans"
    t.index ["loan_id", "due_date"], name: "idx_amortization_schedule_entries_loans_principal_interest", where: "((interest > (0)::numeric) AND (principal > (0)::numeric))"
    t.index ["loan_id"], name: "index_amortization_schedule_entries_on_loan_id"
  end

  create_table "announcements", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.uuid "user_id"
    t.string "status"
    t.boolean "is_published"
    t.uuid "branch_id"
    t.date "announced_at"
    t.date "published_at"
    t.index ["branch_id"], name: "index_announcements_on_branch_id"
  end

  create_table "api_receive_members", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.date "receive_date"
    t.string "api_from"
    t.uuid "branch_id"
    t.json "data"
    t.string "status"
    t.date "date_approve"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "inforce_count"
    t.integer "lapsed_count"
    t.integer "pending_count"
  end

  create_table "areas", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "short_name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "attachment_files", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "member_id"
    t.string "file_name"
    t.jsonb "data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["member_id"], name: "index_attachment_files_on_member_id"
  end

  create_table "bank_transfers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.decimal "amount"
    t.jsonb "data"
    t.uuid "accounting_entry_id"
    t.uuid "transfer_option_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["transfer_option_id"], name: "index_bank_transfers_on_transfer_option_id"
  end

  create_table "beneficiaries", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "member_id"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "relationship"
    t.date "date_of_birth"
    t.boolean "is_primary"
    t.boolean "is_deceased"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["member_id"], name: "index_beneficiaries_on_member_id"
  end

  create_table "billings", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.date "collection_date"
    t.uuid "center_id"
    t.uuid "branch_id"
    t.jsonb "data"
    t.string "status"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.date "date_approved"
    t.string "or_number"
    t.string "ar_number"
    t.decimal "total_collected"
    t.decimal "total_expected_collections"
    t.string "si_number"
    t.index ["branch_id"], name: "index_billings_on_branch_id"
    t.index ["center_id"], name: "index_billings_on_center_id"
    t.index ["status", "collection_date"], name: "idx_billings_status_collection_date"
  end

  create_table "branch_psr_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "branch_id", null: false
    t.date "closing_date"
    t.integer "closing_year"
    t.integer "closing_month"
    t.jsonb "data"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_branch_psr_records_on_branch_id"
  end

  create_table "branches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "cluster_id"
    t.string "name"
    t.string "short_name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "member_counter"
    t.date "current_date"
    t.string "color"
    t.boolean "is_main"
    t.string "or_prefix"
    t.integer "or_counter", default: 0
    t.integer "or_current_max"
    t.string "ar_prefix"
    t.integer "ar_counter", default: 0
    t.integer "ar_current_max"
    t.decimal "lat"
    t.decimal "lon"
    t.index ["cluster_id"], name: "index_branches_on_cluster_id"
  end

  create_table "calamity_claims", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "member_id"
    t.uuid "center_id"
    t.uuid "branch_id"
    t.date "date_requested"
    t.string "purpose"
    t.string "type_of_calamity"
    t.string "amount"
    t.date "date_of_event"
    t.date "date_approved"
    t.date "date_of_notification"
    t.string "name_of_payee"
    t.string "name_of_beneficiary"
    t.string "prepared_by"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "claim_type"
    t.json "data"
    t.index ["branch_id"], name: "index_calamity_claims_on_branch_id"
    t.index ["center_id"], name: "index_calamity_claims_on_center_id"
    t.index ["member_id"], name: "index_calamity_claims_on_member_id"
  end

  create_table "centers", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "branch_id"
    t.string "name"
    t.string "short_name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "meeting_day"
    t.uuid "user_id"
    t.decimal "lat"
    t.decimal "lon"
    t.index ["branch_id"], name: "index_centers_on_branch_id"
  end

  create_table "claim_attachment_files", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "claim_id"
    t.string "file_name"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["claim_id"], name: "index_claim_attachment_files_on_claim_id"
  end

  create_table "claims", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.uuid "member_id"
    t.uuid "center_id"
    t.uuid "branch_id"
    t.string "claim_type"
    t.json "data"
    t.string "status"
    t.string "approved_by"
    t.string "checked_by"
    t.date "date_checked"
    t.date "date_approved"
    t.string "posted_by"
    t.date "date_posted"
    t.uuid "external_ref"
    t.index ["branch_id"], name: "index_claims_on_branch_id"
    t.index ["center_id"], name: "index_claims_on_center_id"
    t.index ["member_id"], name: "index_claims_on_member_id"
  end

  create_table "clip_claims", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "member_id"
    t.uuid "center_id"
    t.uuid "branch_id"
    t.date "date_prepared"
    t.string "creditors_name"
    t.string "policy_number"
    t.date "date_of_birth"
    t.string "member_name"
    t.string "beneficiary"
    t.string "gender"
    t.string "age"
    t.date "date_of_death"
    t.text "cause_of_death"
    t.date "effective_date_of_coverage"
    t.date "expiration_date_of_coverage"
    t.decimal "amount_of_loan"
    t.string "terms"
    t.decimal "amount_payable_to_beneficiary"
    t.string "prepared_by"
    t.decimal "amount_payable_to_creditor"
    t.string "type_of_loan"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "claim_type"
    t.json "data"
    t.index ["branch_id"], name: "index_clip_claims_on_branch_id"
    t.index ["center_id"], name: "index_clip_claims_on_center_id"
    t.index ["member_id"], name: "index_clip_claims_on_member_id"
  end

  create_table "clusters", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "area_id"
    t.string "name"
    t.string "short_name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["area_id"], name: "index_clusters_on_area_id"
  end

  create_table "commission_collections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.date "date_approved"
    t.date "date_prepared"
    t.jsonb "data"
    t.jsonb "meta"
    t.string "status"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "daily_branch_metrics", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "principal"
    t.decimal "interest"
    t.decimal "total"
    t.decimal "principal_due"
    t.decimal "interest_due"
    t.decimal "total_due"
    t.decimal "principal_paid"
    t.decimal "interest_paid"
    t.decimal "principal_paid_due"
    t.decimal "portfolio"
    t.decimal "interest_paid_due"
    t.decimal "total_paid_due"
    t.decimal "total_paid"
    t.decimal "principal_balance"
    t.decimal "interest_balance"
    t.decimal "total_balance"
    t.decimal "overall_principal_balance"
    t.decimal "overall_interest_balance"
    t.decimal "overall_balance"
    t.decimal "principal_rr"
    t.decimal "interest_rr"
    t.decimal "total_rr"
    t.decimal "par_amount"
    t.decimal "par"
    t.integer "num_days_par"
    t.string "status"
    t.date "as_of"
    t.jsonb "data"
    t.uuid "branch_id", null: false
    t.uuid "cluster_id", null: false
    t.uuid "area_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id"], name: "index_daily_branch_metrics_on_area_id"
    t.index ["branch_id"], name: "index_daily_branch_metrics_on_branch_id"
    t.index ["cluster_id"], name: "index_daily_branch_metrics_on_cluster_id"
  end

  create_table "data_stores", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.json "meta"
    t.json "data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "status"
    t.date "as_of"
    t.date "start_date"
    t.date "end_date"
    t.index "((meta ->> 'data_store_type'::text)), ((meta ->> 'branch_id'::text)), ((meta ->> 'as_of'::text)) DESC", name: "manual_idx_11"
    t.index "status, ((meta ->> 'data_store_type'::text)), ((meta ->> 'branch_id'::text)), ((meta ->> 'as_of'::text)) DESC", name: "manual_idx_5"
  end

  create_table "deposit_collections", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.date "collection_date"
    t.uuid "center_id"
    t.uuid "branch_id"
    t.jsonb "data"
    t.string "status"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.date "date_approved"
    t.index ["branch_id"], name: "index_deposit_collections_on_branch_id"
    t.index ["center_id"], name: "index_deposit_collections_on_center_id"
  end

  create_table "dw_branch_active_loan_counts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "branch_id", null: false
    t.uuid "cluster_id", null: false
    t.uuid "area_id", null: false
    t.string "status"
    t.date "as_of"
    t.jsonb "data"
    t.integer "total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "month"
    t.integer "year"
    t.index ["area_id"], name: "index_dw_branch_active_loan_counts_on_area_id"
    t.index ["branch_id"], name: "index_dw_branch_active_loan_counts_on_branch_id"
    t.index ["cluster_id"], name: "index_dw_branch_active_loan_counts_on_cluster_id"
  end

  create_table "dw_branch_loan_past_dues", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "branch_id", null: false
    t.uuid "area_id", null: false
    t.uuid "cluster_id", null: false
    t.decimal "amount"
    t.jsonb "data"
    t.string "record_type"
    t.string "status"
    t.integer "month"
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id"], name: "index_dw_branch_loan_past_dues_on_area_id"
    t.index ["branch_id"], name: "index_dw_branch_loan_past_dues_on_branch_id"
    t.index ["cluster_id"], name: "index_dw_branch_loan_past_dues_on_cluster_id"
  end

  create_table "dw_branch_loan_product_active_loan_counts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "branch_id", null: false
    t.uuid "cluster_id", null: false
    t.uuid "area_id", null: false
    t.string "status"
    t.date "as_of"
    t.jsonb "data"
    t.integer "total"
    t.uuid "loan_product_id", null: false
    t.uuid "loan_product_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "month"
    t.integer "year"
    t.index ["area_id"], name: "dw_a_lp_alc_index"
    t.index ["branch_id"], name: "dw_b_lp_alc_index"
    t.index ["cluster_id"], name: "dw_c_lp_alc_index"
    t.index ["loan_product_category_id"], name: "dw_lpc_alc_index"
    t.index ["loan_product_id"], name: "dw_lp_alc_index"
  end

  create_table "dw_branch_loan_product_outstanding_loan_amounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "branch_id", null: false
    t.uuid "cluster_id", null: false
    t.uuid "area_id", null: false
    t.string "status"
    t.jsonb "data"
    t.decimal "amount"
    t.uuid "loan_product_category_id", null: false
    t.uuid "loan_product_id", null: false
    t.date "as_of"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id"], name: "dw_b_lp_a_ola_index"
    t.index ["branch_id"], name: "dw_b_lp_ola_index"
    t.index ["cluster_id"], name: "dw_b_lp_c_ola_index"
    t.index ["loan_product_category_id"], name: "dw_b_lp_lpc_ola_index"
    t.index ["loan_product_id"], name: "dw_b_lp_lp_ola_index"
  end

  create_table "dw_branch_member_counts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "branch_id", null: false
    t.uuid "cluster_id", null: false
    t.uuid "area_id", null: false
    t.string "status"
    t.date "as_of"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "count_male"
    t.integer "count_female"
    t.integer "total"
    t.string "record_type"
    t.integer "count_others"
    t.integer "month"
    t.integer "year"
    t.index ["area_id"], name: "index_dw_branch_member_counts_on_area_id"
    t.index ["branch_id"], name: "index_dw_branch_member_counts_on_branch_id"
    t.index ["cluster_id"], name: "index_dw_branch_member_counts_on_cluster_id"
  end

  create_table "dw_branch_monthly_loan_amount_collections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "branch_id", null: false
    t.uuid "area_id", null: false
    t.uuid "cluster_id", null: false
    t.decimal "amount"
    t.jsonb "data"
    t.string "status"
    t.integer "month"
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id"], name: "index_dw_branch_monthly_loan_amount_collections_on_area_id"
    t.index ["branch_id"], name: "index_dw_branch_monthly_loan_amount_collections_on_branch_id"
    t.index ["cluster_id"], name: "index_dw_branch_monthly_loan_amount_collections_on_cluster_id"
  end

  create_table "dw_branch_monthly_loan_amount_dues", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "branch_id", null: false
    t.uuid "area_id", null: false
    t.uuid "cluster_id", null: false
    t.decimal "amount"
    t.jsonb "data"
    t.string "status"
    t.integer "month"
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id"], name: "index_dw_branch_monthly_loan_amount_dues_on_area_id"
    t.index ["branch_id"], name: "index_dw_branch_monthly_loan_amount_dues_on_branch_id"
    t.index ["cluster_id"], name: "index_dw_branch_monthly_loan_amount_dues_on_cluster_id"
  end

  create_table "dw_branch_monthly_loan_product_disbursed_counts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "branch_id", null: false
    t.uuid "area_id", null: false
    t.uuid "cluster_id", null: false
    t.uuid "loan_product_id", null: false
    t.uuid "loan_product_category_id", null: false
    t.integer "month"
    t.integer "year"
    t.string "status"
    t.integer "total"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "amount"
    t.index ["area_id"], name: "dw_a_m_lpdc_index"
    t.index ["branch_id"], name: "dw_b_m_lpdc_index"
    t.index ["cluster_id"], name: "dw_c_m_lpdc_index"
    t.index ["loan_product_category_id"], name: "dw_lpc_m_lpdc_index"
    t.index ["loan_product_id"], name: "dw_lp_m_lpdc_index"
  end

  create_table "dw_branch_new_member_counts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "branch_id", null: false
    t.uuid "cluster_id", null: false
    t.uuid "area_id", null: false
    t.string "status"
    t.jsonb "data"
    t.integer "total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "month"
    t.integer "year"
    t.index ["area_id"], name: "index_dw_branch_new_member_counts_on_area_id"
    t.index ["branch_id"], name: "index_dw_branch_new_member_counts_on_branch_id"
    t.index ["cluster_id"], name: "index_dw_branch_new_member_counts_on_cluster_id"
  end

  create_table "dw_branch_par_amounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "branch_id", null: false
    t.uuid "area_id", null: false
    t.uuid "cluster_id", null: false
    t.decimal "amount"
    t.jsonb "data"
    t.string "record_type"
    t.string "status"
    t.integer "month"
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id"], name: "index_dw_branch_par_amounts_on_area_id"
    t.index ["branch_id"], name: "index_dw_branch_par_amounts_on_branch_id"
    t.index ["cluster_id"], name: "index_dw_branch_par_amounts_on_cluster_id"
  end

  create_table "dw_branch_resigned_member_counts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "branch_id", null: false
    t.uuid "cluster_id", null: false
    t.uuid "area_id", null: false
    t.integer "total"
    t.integer "month"
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id"], name: "index_dw_branch_resigned_member_counts_on_area_id"
    t.index ["branch_id"], name: "index_dw_branch_resigned_member_counts_on_branch_id"
    t.index ["cluster_id"], name: "index_dw_branch_resigned_member_counts_on_cluster_id"
  end

  create_table "equity_withdrawal_collections", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.date "collection_date"
    t.uuid "center_id"
    t.uuid "branch_id"
    t.jsonb "data"
    t.string "status"
    t.date "date_approved"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["branch_id"], name: "index_equity_withdrawal_collections_on_branch_id"
    t.index ["center_id"], name: "index_equity_withdrawal_collections_on_center_id"
  end

  create_table "file_repositories", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "file_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hiip_claims", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "member_id"
    t.uuid "center_id"
    t.uuid "branch_id"
    t.date "date_posted"
    t.decimal "amount"
    t.text "mode_of_payment"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "policy_number"
    t.date "effective_date_of_coverage"
    t.date "expiration_date_of_coverage"
    t.date "date_admitted"
    t.date "date_discharged"
    t.string "number_ofdays_tobepaid"
    t.date "date_of_birth"
    t.string "age"
    t.text "reason_of_confinement"
    t.text "diagnosis"
    t.string "check_payee"
    t.string "prepared_by"
    t.decimal "balance"
    t.string "claim_type"
    t.json "data"
    t.date "date_prepared"
    t.index ["branch_id"], name: "index_hiip_claims_on_branch_id"
    t.index ["center_id"], name: "index_hiip_claims_on_center_id"
    t.index ["member_id"], name: "index_hiip_claims_on_member_id"
  end

  create_table "holidays", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "holiday_name"
    t.string "holiday_date"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "insurance_fund_transfer_collections", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.date "collection_date"
    t.uuid "center_id"
    t.uuid "branch_id"
    t.jsonb "data"
    t.string "status"
    t.date "date_approved"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["branch_id"], name: "index_insurance_fund_transfer_collections_on_branch_id"
    t.index ["center_id"], name: "index_insurance_fund_transfer_collections_on_center_id"
  end

  create_table "insurance_loan_bundle_enrollments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "status"
    t.uuid "center_id"
    t.uuid "branch_id"
    t.date "collection_date"
    t.date "date_approved"
    t.jsonb "data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.decimal "total_amount", precision: 8, scale: 2, default: "0.0"
    t.string "approved_by"
    t.index ["branch_id"], name: "index_insurance_loan_bundle_enrollments_on_branch_id"
    t.index ["center_id"], name: "index_insurance_loan_bundle_enrollments_on_center_id"
  end

  create_table "insurance_monthly_closing_collections", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "branch_id"
    t.date "closing_date"
    t.date "closed_at"
    t.jsonb "data"
    t.jsonb "meta"
    t.string "status"
    t.string "account_subtype"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_insurance_monthly_closing_collections_on_branch_id"
  end

  create_table "insurance_withdrawal_collections", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.date "collection_date"
    t.uuid "center_id"
    t.uuid "branch_id"
    t.jsonb "data"
    t.string "status"
    t.date "date_approved"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["branch_id"], name: "index_insurance_withdrawal_collections_on_branch_id"
    t.index ["center_id"], name: "index_insurance_withdrawal_collections_on_center_id"
  end

  create_table "interests", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "member_account_id"
    t.uuid "account_transaction_id"
    t.date "month_of_year_date"
    t.decimal "interest_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "interest_type"
    t.index ["account_transaction_id"], name: "index_interests_on_account_transaction_id"
    t.index ["member_account_id"], name: "index_interests_on_member_account_id"
  end

  create_table "journal_entries", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "post_type"
    t.uuid "accounting_code_id"
    t.uuid "accounting_entry_id"
    t.json "data"
    t.decimal "amount"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "book"
    t.uuid "branch_id"
    t.uuid "accounting_fund_id"
    t.string "status"
    t.date "date_prepared"
    t.date "ae_date_posted"
    t.index ["accounting_code_id", "accounting_entry_id"], name: "manual_idx_10"
    t.index ["accounting_code_id"], name: "index_journal_entries_on_accounting_code_id"
    t.index ["accounting_entry_id", "post_type", "accounting_code_id"], name: "manual_idx_18"
    t.index ["accounting_entry_id"], name: "index_journal_entries_on_accounting_entry_id"
    t.index ["accounting_fund_id"], name: "index_journal_entries_on_accounting_fund_id"
    t.index ["branch_id"], name: "index_journal_entries_on_branch_id"
  end

  create_table "kalinga_claims", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.date "date_reported"
    t.date "date_emailed"
    t.date "date_approved"
    t.date "date_requested"
    t.string "purpose"
    t.decimal "amount"
    t.date "effective_date"
    t.date "expiration_date"
    t.string "poc_number"
    t.string "name_of_insured"
    t.string "relationship_to_member"
    t.string "insured_address"
    t.string "civil_status"
    t.date "date_of_birth"
    t.string "name_of_beneficiary"
    t.date "date_of_death_or_incident"
    t.text "reason_of_death"
    t.string "gender"
    t.string "prepared_by"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.date "issueddate"
    t.string "claim_type"
    t.json "data"
    t.uuid "member_id"
    t.uuid "center_id"
    t.uuid "branch_id"
    t.index ["branch_id"], name: "index_kalinga_claims_on_branch_id"
    t.index ["center_id"], name: "index_kalinga_claims_on_center_id"
    t.index ["member_id"], name: "index_kalinga_claims_on_member_id"
  end

  create_table "kbente_claims", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "member_id"
    t.uuid "center_id"
    t.uuid "branch_id"
    t.date "date_reported"
    t.date "date_emailed"
    t.date "date_approved"
    t.date "date_requested"
    t.string "purpose"
    t.decimal "amount"
    t.string "prepared_by"
    t.string "name_of_insured"
    t.string "name_of_beneficiary"
    t.string "classification"
    t.date "date_of_death"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "claim_type"
    t.json "data"
    t.index ["branch_id"], name: "index_kbente_claims_on_branch_id"
    t.index ["center_id"], name: "index_kbente_claims_on_center_id"
    t.index ["member_id"], name: "index_kbente_claims_on_member_id"
  end

  create_table "kjsp_claims", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "member_id"
    t.uuid "center_id"
    t.uuid "branch_id"
    t.date "date_prepared"
    t.string "name_of_kjsp_beneficiary"
    t.string "payee"
    t.string "amount"
    t.string "name_of_school"
    t.string "school_year"
    t.string "year_level"
    t.string "sem"
    t.string "kjsp_type"
    t.string "final_grade"
    t.string "remarks"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "classification"
    t.string "received_by"
    t.string "prepared_by"
    t.string "course"
    t.string "claim_type"
    t.json "data"
    t.index ["branch_id"], name: "index_kjsp_claims_on_branch_id"
    t.index ["center_id"], name: "index_kjsp_claims_on_center_id"
    t.index ["member_id"], name: "index_kjsp_claims_on_member_id"
  end

  create_table "kpf_loan_clips", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "status"
    t.uuid "center_id"
    t.uuid "branch_id"
    t.date "collection_date"
    t.date "date_approved"
    t.jsonb "data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.decimal "total_amount", precision: 8, scale: 2, default: "0.0"
    t.string "approved_by"
    t.index ["branch_id"], name: "index_kpf_loan_clips_on_branch_id"
    t.index ["center_id"], name: "index_kpf_loan_clips_on_center_id"
  end

  create_table "legal_dependents", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name"
    t.string "middle_name"
    t.date "date_of_birth"
    t.uuid "member_id"
    t.string "relationship"
    t.json "data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "last_name"
    t.string "gender"
    t.index ["member_id"], name: "index_legal_dependents_on_member_id"
  end

  create_table "loan_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "loan_product_id", null: false
    t.decimal "amount", null: false
    t.string "term", null: false
    t.integer "num_installments", null: false
    t.uuid "member_id", null: false
    t.jsonb "data"
    t.string "status", null: false
    t.date "date_applied", null: false
    t.string "reference_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "co_maker_member_id"
    t.string "co_maker_first_name", null: false
    t.string "co_maker_last_name", null: false
    t.uuid "loan_product_tagging_id"
    t.date "date_approved"
    t.index ["loan_product_id"], name: "index_loan_applications_on_loan_product_id"
    t.index ["loan_product_tagging_id"], name: "index_loan_applications_on_loan_product_tagging_id"
    t.index ["member_id"], name: "index_loan_applications_on_member_id"
  end

  create_table "loan_product_categories", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "loan_product_taggings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "loan_product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["loan_product_id"], name: "index_loan_product_taggings_on_loan_product_id"
  end

  create_table "loan_product_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "loan_product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["loan_product_id"], name: "index_loan_product_types_on_loan_product_id"
  end

  create_table "loan_products", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.decimal "max_loan_amount"
    t.decimal "min_loan_amount"
    t.decimal "denomination"
    t.boolean "insured"
    t.boolean "is_entry_point"
    t.decimal "monthly_interest_rate"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.json "data"
    t.integer "priority"
    t.uuid "loan_product_category_id"
    t.boolean "is_active"
    t.index ["loan_product_category_id"], name: "index_loan_products_on_loan_product_category_id"
    t.index ["priority"], name: "manual_idx_6"
  end

  create_table "loan_repayment_rates", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "loan_id"
    t.date "as_of"
    t.uuid "branch_id"
    t.uuid "center_id"
    t.jsonb "data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["branch_id"], name: "index_loan_repayment_rates_on_branch_id"
    t.index ["center_id"], name: "index_loan_repayment_rates_on_center_id"
    t.index ["loan_id"], name: "index_loan_repayment_rates_on_loan_id"
  end

  create_table "loans", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.date "first_date_of_payment"
    t.integer "cycle"
    t.date "maturity_date"
    t.date "max_active_date"
    t.uuid "user_id"
    t.date "original_maturity_date"
    t.boolean "is_restructured"
    t.uuid "loan_product_type_id"
    t.boolean "is_online_application"
    t.string "loan_product_tagging_id"
    t.index ["branch_id"], name: "index_loans_on_branch_id"
    t.index ["center_id"], name: "index_loans_on_center_id"
    t.index ["loan_product_id"], name: "index_loans_on_loan_product_id"
    t.index ["loan_product_type_id"], name: "index_loans_on_loan_product_type_id"
    t.index ["member_id"], name: "index_loans_on_member_id"
    t.index ["project_type_id"], name: "index_loans_on_project_type_id"
  end

  create_table "make_payments", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "member_id", null: false
    t.date "transaction_date"
    t.date "date_approve"
    t.string "approved_by"
    t.string "created_by"
    t.json "data"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "make_payment_type"
    t.json "meta"
    t.index ["member_id"], name: "index_make_payments_on_member_id"
  end

  create_table "member_account_daily_statements", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "member_id", null: false
    t.uuid "member_account_id", null: false
    t.date "transacted_at"
    t.uuid "branch_id", null: false
    t.decimal "debit_amount"
    t.decimal "credit_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_member_account_daily_statements_on_branch_id"
    t.index ["member_account_id"], name: "index_member_account_daily_statements_on_member_account_id"
    t.index ["member_id", "member_account_id", "branch_id", "transacted_at"], name: "idx_macds_m_ma_b_t"
    t.index ["member_id"], name: "index_member_account_daily_statements_on_member_id"
  end

  create_table "member_account_validation_cancellations", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "member_account_validation_id"
    t.uuid "member_id"
    t.uuid "branch_id"
    t.text "reason"
    t.date "date_cancelled"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["branch_id"], name: "index_member_account_validation_cancellations_on_branch_id"
    t.index ["member_account_validation_id"], name: "index_member_account_validation_cancellations_uniqueness"
    t.index ["member_id"], name: "index_member_account_validation_cancellations_on_member_id"
  end

  create_table "member_account_validation_records", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "member_account_validation_id"
    t.uuid "member_id"
    t.uuid "center_id"
    t.string "status"
    t.string "transaction_number"
    t.decimal "rf"
    t.decimal "lif_50_percent"
    t.decimal "advance_rf"
    t.decimal "interest"
    t.decimal "equity_interest"
    t.decimal "total"
    t.date "resignation_date"
    t.string "member_classification"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.decimal "advance_lif"
    t.json "data"
    t.decimal "equity_value"
    t.decimal "policy_loan"
    t.index ["center_id"], name: "index_member_account_validation_records_on_center_id"
    t.index ["member_account_validation_id"], name: "index_member_account_validation_records_uniqueness"
    t.index ["member_id"], name: "index_member_account_validation_records_on_member_id"
  end

  create_table "member_account_validations", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "branch_id"
    t.date "date_prepared"
    t.string "status"
    t.string "prepared_by"
    t.string "approved_by"
    t.text "particular"
    t.string "reference_number"
    t.decimal "total"
    t.string "or_number"
    t.date "date_approved"
    t.date "date_validated"
    t.string "validated_by"
    t.date "date_checked"
    t.string "checked_by"
    t.date "date_cancelled"
    t.string "cancelled_by"
    t.boolean "is_remote"
    t.decimal "total_rf"
    t.decimal "total_50_percent_lif"
    t.decimal "total_advance_lif"
    t.decimal "total_advance_rf"
    t.decimal "total_interest"
    t.decimal "total_equity_interest"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.json "data"
    t.decimal "total_policy_loan"
    t.index ["branch_id"], name: "index_member_account_validations_on_branch_id"
  end

  create_table "member_accounts", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "member_id"
    t.string "account_type"
    t.string "account_subtype"
    t.decimal "balance"
    t.uuid "center_id"
    t.uuid "branch_id"
    t.string "status"
    t.decimal "maintaining_balance"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.json "data"
    t.index ["account_type", "account_subtype"], name: "manual_idx_12"
    t.index ["branch_id"], name: "index_member_accounts_on_branch_id"
    t.index ["center_id"], name: "index_member_accounts_on_center_id"
    t.index ["member_id"], name: "index_member_accounts_on_member_id"
  end

  create_table "member_loan_moratoria", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "member_moratorium_id"
    t.uuid "loan_id", null: false
    t.uuid "branch_id", null: false
    t.uuid "center_id", null: false
    t.uuid "member_id", null: false
    t.date "date_initialized"
    t.string "status"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "number_of_days"
    t.string "reason"
    t.index ["branch_id"], name: "index_member_loan_moratoria_on_branch_id"
    t.index ["center_id"], name: "index_member_loan_moratoria_on_center_id"
    t.index ["loan_id"], name: "index_member_loan_moratoria_on_loan_id"
    t.index ["member_id"], name: "index_member_loan_moratoria_on_member_id"
    t.index ["member_moratorium_id"], name: "index_member_loan_moratoria_on_member_moratorium_id"
  end

  create_table "member_moratoria", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "status"
    t.uuid "branch_id", null: false
    t.uuid "center_id", null: false
    t.uuid "member_id", null: false
    t.date "date_initialized"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "number_of_days"
    t.string "reason"
    t.index ["branch_id"], name: "index_member_moratoria_on_branch_id"
    t.index ["center_id"], name: "index_member_moratoria_on_center_id"
    t.index ["member_id"], name: "index_member_moratoria_on_member_id"
  end

  create_table "member_shares", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "member_id"
    t.string "certificate_number"
    t.jsonb "data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.date "date_of_issue"
    t.boolean "is_void"
    t.integer "number_of_shares"
    t.string "certificate_for"
    t.index ["member_id"], name: "index_member_shares_on_member_id"
  end

  create_table "members", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "access_token"
    t.text "signature_data"
    t.boolean "modifiable"
    t.date "previous_date_resigned"
    t.date "insurance_date_resigned"
    t.uuid "member_id"
    t.string "encrypted_password"
    t.string "username"
    t.uuid "online_application_id"
    t.uuid "membership_arrangement_id"
    t.uuid "membership_type_id"
    t.uuid "referrer_id"
    t.uuid "coordinator_id"
    t.string "email"
    t.uuid "external_ref"
    t.index ["branch_id"], name: "index_members_on_branch_id"
    t.index ["center_id"], name: "index_members_on_center_id"
    t.index ["member_id"], name: "index_members_on_member_id"
    t.index ["membership_arrangement_id"], name: "index_members_on_membership_arrangement_id"
    t.index ["membership_type_id"], name: "index_members_on_membership_type_id"
    t.index ["online_application_id"], name: "index_members_on_online_application_id"
    t.index ["referrer_id"], name: "index_members_on_referrer_id"
    t.index ["status", "center_id"], name: "manual_idx_7"
  end

  create_table "membership_arrangements", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "membership_payment_collections", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.date "collection_date"
    t.uuid "center_id"
    t.uuid "branch_id"
    t.jsonb "data"
    t.string "status"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.date "date_approved"
    t.string "or_number"
    t.string "ar_number"
    t.decimal "total_collected"
    t.string "si_number"
    t.index ["branch_id"], name: "index_membership_payment_collections_on_branch_id"
    t.index ["center_id"], name: "index_membership_payment_collections_on_center_id"
  end

  create_table "membership_payment_records", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "membership_type"
    t.string "membership_name"
    t.decimal "amount"
    t.date "date_paid"
    t.string "status"
    t.uuid "member_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.date "date_voided"
    t.index ["member_id"], name: "index_membership_payment_records_on_member_id"
  end

  create_table "membership_types", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "topic"
    t.text "content"
    t.uuid "member_id", null: false
    t.string "status"
    t.uuid "message_id"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.index ["member_id"], name: "index_messages_on_member_id"
    t.index ["message_id"], name: "index_messages_on_message_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "monthly_accounting_code_summaries", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.integer "month"
    t.integer "year"
    t.uuid "branch_id", null: false
    t.uuid "accounting_code_id", null: false
    t.string "category"
    t.string "name"
    t.decimal "dr_amount"
    t.decimal "cr_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["accounting_code_id"], name: "index_monthly_accounting_code_summaries_on_accounting_code_id"
    t.index ["branch_id"], name: "index_monthly_accounting_code_summaries_on_branch_id"
    t.index ["month", "year", "accounting_code_id", "branch_id"], name: "idx_macs_m_y_ac_id_b_id"
  end

  create_table "monthly_closing_collections", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.date "closing_date"
    t.date "closed_at"
    t.jsonb "data"
    t.jsonb "meta"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.uuid "branch_id"
    t.string "status"
    t.string "account_subtype"
    t.index ["branch_id", "closing_date"], name: "manual_idx_3", order: { closing_date: :desc }
    t.index ["branch_id"], name: "index_monthly_closing_collections_on_branch_id"
    t.index ["closing_date"], name: "manual_idx_2", order: :desc
  end

  create_table "online_application_documents", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "file_name"
    t.jsonb "data"
    t.uuid "online_application_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["online_application_id"], name: "index_online_application_documents_on_online_application_id"
  end

  create_table "online_applications", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "gender"
    t.date "date_of_birth"
    t.string "civil_status"
    t.string "home_number"
    t.string "mobile_number"
    t.string "reference_number"
    t.string "status"
    t.string "place_of_birth"
    t.string "religion"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "branch_id"
    t.boolean "agreed_to_dp_terms"
    t.uuid "membership_type_id"
    t.uuid "membership_arrangement_id"
    t.uuid "center_id"
    t.string "email"
    t.index ["branch_id"], name: "index_online_applications_on_branch_id"
    t.index ["center_id"], name: "index_online_applications_on_center_id"
    t.index ["membership_arrangement_id"], name: "index_online_applications_on_membership_arrangement_id"
    t.index ["membership_type_id"], name: "index_online_applications_on_membership_type_id"
    t.index ["mobile_number"], name: "idx_mobile_number_oa"
    t.index ["reference_number"], name: "idx_online_applications_reference_number"
  end

  create_table "project_type_categories", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "is_active"
  end

  create_table "project_types", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.uuid "project_type_category_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "is_active"
    t.index ["project_type_category_id"], name: "index_project_types_on_project_type_category_id"
  end

  create_table "recompute_restructures", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "branch", null: false
    t.string "center", null: false
    t.string "status"
    t.date "transaction_date"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "member"
    t.string "loan"
  end

  create_table "referrers", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "status"
    t.string "contact_number"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date_registered"
    t.string "category"
  end

  create_table "savings_insurance_transfer_collections", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "status"
    t.uuid "center_id"
    t.uuid "branch_id"
    t.date "collection_date"
    t.date "date_approved"
    t.jsonb "data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.decimal "total_amount", precision: 8, scale: 2, default: "0.0"
    t.string "approved_by"
    t.index ["branch_id"], name: "index_savings_insurance_transfer_collections_on_branch_id"
    t.index ["center_id"], name: "index_savings_insurance_transfer_collections_on_center_id"
  end

  create_table "survey_answers", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "survey_id"
    t.jsonb "meta"
    t.jsonb "data"
    t.string "status"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["survey_id"], name: "index_survey_answers_on_survey_id"
  end

  create_table "survey_questions", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "survey_id"
    t.string "content"
    t.string "question_type"
    t.jsonb "data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "priority"
    t.index ["survey_id"], name: "index_survey_questions_on_survey_id"
  end

  create_table "surveys", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.jsonb "data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "status"
  end

  create_table "time_deposit_collections", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.date "collection_date"
    t.uuid "center_id"
    t.uuid "branch_id"
    t.jsonb "data"
    t.string "status"
    t.date "date_approved"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["branch_id"], name: "index_time_deposit_collections_on_branch_id"
    t.index ["center_id"], name: "index_time_deposit_collections_on_center_id"
  end

  create_table "transfer_member_records", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "branch_id"
    t.date "transfer_date"
    t.string "status"
    t.date "date_approved"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "branch_id_to_transfer"
  end

  create_table "transfer_options", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transfer_savings_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "branch_id"
    t.uuid "center_id"
    t.date "date_approved"
    t.string "status"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_transfer_savings_records_on_branch_id"
    t.index ["center_id"], name: "index_transfer_savings_records_on_center_id"
  end

  create_table "user_branches", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.uuid "branch_id"
    t.boolean "active"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "user_demerits", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.uuid "branch_id"
    t.string "status"
    t.string "demerit_type"
    t.string "role"
    t.date "date_prepared"
    t.date "date_approved"
    t.date "date_of_action"
    t.text "reason"
    t.text "explanation"
    t.json "data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["branch_id"], name: "index_user_demerits_on_branch_id"
    t.index ["user_id"], name: "index_user_demerits_on_user_id"
  end

  create_table "user_tasks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "status"
    t.string "task_type"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_tasks_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "username"
    t.string "first_name"
    t.string "last_name"
    t.string "identification_number"
    t.string "roles"
    t.boolean "is_regular"
    t.date "incentivized_date"
    t.string "access_token"
    t.boolean "is_verified"
    t.string "verification_token"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "withdrawal_collections", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.date "collection_date"
    t.uuid "center_id"
    t.uuid "branch_id"
    t.jsonb "data"
    t.string "status"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.date "date_approved"
    t.index ["branch_id"], name: "index_withdrawal_collections_on_branch_id"
    t.index ["center_id"], name: "index_withdrawal_collections_on_center_id"
  end

  add_foreign_key "account_transaction_collections", "branches"
  add_foreign_key "account_transaction_collections", "centers"
  add_foreign_key "accounting_code_balances", "accounting_codes"
  add_foreign_key "accounting_code_balances", "accounting_funds"
  add_foreign_key "accounting_code_balances", "branches"
  add_foreign_key "accounting_entries", "accounting_funds"
  add_foreign_key "accounting_entries", "branches"
  add_foreign_key "accrued_billings", "branches"
  add_foreign_key "accrued_billings", "centers"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "administration_branch_closing_records", "branches"
  add_foreign_key "administration_branch_closing_records", "data_stores"
  add_foreign_key "amortization_schedule_entries", "loans"
  add_foreign_key "announcements", "branches"
  add_foreign_key "attachment_files", "members"
  add_foreign_key "bank_transfers", "transfer_options"
  add_foreign_key "beneficiaries", "members"
  add_foreign_key "billings", "branches"
  add_foreign_key "billings", "centers"
  add_foreign_key "branch_psr_records", "branches"
  add_foreign_key "branches", "clusters"
  add_foreign_key "calamity_claims", "branches"
  add_foreign_key "calamity_claims", "centers"
  add_foreign_key "calamity_claims", "members"
  add_foreign_key "centers", "branches"
  add_foreign_key "claim_attachment_files", "claims"
  add_foreign_key "claims", "branches"
  add_foreign_key "claims", "centers"
  add_foreign_key "clip_claims", "branches"
  add_foreign_key "clip_claims", "centers"
  add_foreign_key "clip_claims", "members"
  add_foreign_key "clusters", "areas"
  add_foreign_key "daily_branch_metrics", "areas"
  add_foreign_key "daily_branch_metrics", "branches"
  add_foreign_key "daily_branch_metrics", "clusters"
  add_foreign_key "deposit_collections", "branches"
  add_foreign_key "deposit_collections", "centers"
  add_foreign_key "dw_branch_active_loan_counts", "areas"
  add_foreign_key "dw_branch_active_loan_counts", "branches"
  add_foreign_key "dw_branch_active_loan_counts", "clusters"
  add_foreign_key "dw_branch_loan_past_dues", "areas"
  add_foreign_key "dw_branch_loan_past_dues", "branches"
  add_foreign_key "dw_branch_loan_past_dues", "clusters"
  add_foreign_key "dw_branch_loan_product_active_loan_counts", "areas"
  add_foreign_key "dw_branch_loan_product_active_loan_counts", "branches"
  add_foreign_key "dw_branch_loan_product_active_loan_counts", "clusters"
  add_foreign_key "dw_branch_loan_product_active_loan_counts", "loan_product_categories"
  add_foreign_key "dw_branch_loan_product_active_loan_counts", "loan_products"
  add_foreign_key "dw_branch_loan_product_outstanding_loan_amounts", "areas"
  add_foreign_key "dw_branch_loan_product_outstanding_loan_amounts", "branches"
  add_foreign_key "dw_branch_loan_product_outstanding_loan_amounts", "clusters"
  add_foreign_key "dw_branch_loan_product_outstanding_loan_amounts", "loan_product_categories"
  add_foreign_key "dw_branch_loan_product_outstanding_loan_amounts", "loan_products"
  add_foreign_key "dw_branch_member_counts", "areas"
  add_foreign_key "dw_branch_member_counts", "branches"
  add_foreign_key "dw_branch_member_counts", "clusters"
  add_foreign_key "dw_branch_monthly_loan_amount_collections", "areas"
  add_foreign_key "dw_branch_monthly_loan_amount_collections", "branches"
  add_foreign_key "dw_branch_monthly_loan_amount_collections", "clusters"
  add_foreign_key "dw_branch_monthly_loan_amount_dues", "areas"
  add_foreign_key "dw_branch_monthly_loan_amount_dues", "branches"
  add_foreign_key "dw_branch_monthly_loan_amount_dues", "clusters"
  add_foreign_key "dw_branch_monthly_loan_product_disbursed_counts", "areas"
  add_foreign_key "dw_branch_monthly_loan_product_disbursed_counts", "branches"
  add_foreign_key "dw_branch_monthly_loan_product_disbursed_counts", "clusters"
  add_foreign_key "dw_branch_monthly_loan_product_disbursed_counts", "loan_product_categories"
  add_foreign_key "dw_branch_monthly_loan_product_disbursed_counts", "loan_products"
  add_foreign_key "dw_branch_new_member_counts", "areas"
  add_foreign_key "dw_branch_new_member_counts", "branches"
  add_foreign_key "dw_branch_new_member_counts", "clusters"
  add_foreign_key "dw_branch_par_amounts", "areas"
  add_foreign_key "dw_branch_par_amounts", "branches"
  add_foreign_key "dw_branch_par_amounts", "clusters"
  add_foreign_key "dw_branch_resigned_member_counts", "areas"
  add_foreign_key "dw_branch_resigned_member_counts", "branches"
  add_foreign_key "dw_branch_resigned_member_counts", "clusters"
  add_foreign_key "equity_withdrawal_collections", "branches"
  add_foreign_key "equity_withdrawal_collections", "centers"
  add_foreign_key "hiip_claims", "branches"
  add_foreign_key "hiip_claims", "centers"
  add_foreign_key "hiip_claims", "members"
  add_foreign_key "insurance_fund_transfer_collections", "branches"
  add_foreign_key "insurance_fund_transfer_collections", "centers"
  add_foreign_key "insurance_monthly_closing_collections", "branches"
  add_foreign_key "insurance_withdrawal_collections", "branches"
  add_foreign_key "insurance_withdrawal_collections", "centers"
  add_foreign_key "interests", "account_transactions"
  add_foreign_key "interests", "member_accounts"
  add_foreign_key "journal_entries", "accounting_codes"
  add_foreign_key "journal_entries", "accounting_entries"
  add_foreign_key "journal_entries", "accounting_funds"
  add_foreign_key "journal_entries", "branches"
  add_foreign_key "kalinga_claims", "branches"
  add_foreign_key "kalinga_claims", "centers"
  add_foreign_key "kalinga_claims", "members"
  add_foreign_key "kbente_claims", "branches"
  add_foreign_key "kbente_claims", "centers"
  add_foreign_key "kbente_claims", "members"
  add_foreign_key "kjsp_claims", "branches"
  add_foreign_key "kjsp_claims", "centers"
  add_foreign_key "kjsp_claims", "members"
  add_foreign_key "legal_dependents", "members"
  add_foreign_key "loan_applications", "loan_product_taggings"
  add_foreign_key "loan_applications", "loan_products"
  add_foreign_key "loan_applications", "members"
  add_foreign_key "loan_applications", "members", column: "co_maker_member_id"
  add_foreign_key "loan_product_taggings", "loan_products"
  add_foreign_key "loan_product_types", "loan_products"
  add_foreign_key "loan_products", "loan_product_categories"
  add_foreign_key "loan_repayment_rates", "branches"
  add_foreign_key "loan_repayment_rates", "centers"
  add_foreign_key "loan_repayment_rates", "loans"
  add_foreign_key "loans", "branches"
  add_foreign_key "loans", "centers"
  add_foreign_key "loans", "loan_product_types"
  add_foreign_key "loans", "loan_products"
  add_foreign_key "loans", "members"
  add_foreign_key "loans", "project_types"
  add_foreign_key "make_payments", "members"
  add_foreign_key "member_account_daily_statements", "branches"
  add_foreign_key "member_account_daily_statements", "member_accounts"
  add_foreign_key "member_account_daily_statements", "members"
  add_foreign_key "member_account_validation_cancellations", "branches"
  add_foreign_key "member_account_validation_cancellations", "member_account_validations"
  add_foreign_key "member_account_validation_cancellations", "members"
  add_foreign_key "member_account_validation_records", "centers"
  add_foreign_key "member_account_validation_records", "member_account_validations"
  add_foreign_key "member_account_validation_records", "members"
  add_foreign_key "member_account_validations", "branches"
  add_foreign_key "member_accounts", "branches"
  add_foreign_key "member_accounts", "centers"
  add_foreign_key "member_accounts", "members"
  add_foreign_key "member_loan_moratoria", "branches"
  add_foreign_key "member_loan_moratoria", "centers"
  add_foreign_key "member_loan_moratoria", "loans"
  add_foreign_key "member_loan_moratoria", "member_moratoria"
  add_foreign_key "member_loan_moratoria", "members"
  add_foreign_key "member_moratoria", "branches"
  add_foreign_key "member_moratoria", "centers"
  add_foreign_key "member_moratoria", "members"
  add_foreign_key "member_shares", "members"
  add_foreign_key "members", "branches"
  add_foreign_key "members", "centers"
  add_foreign_key "members", "members"
  add_foreign_key "members", "membership_arrangements"
  add_foreign_key "members", "membership_types"
  add_foreign_key "members", "online_applications"
  add_foreign_key "members", "referrers"
  add_foreign_key "membership_payment_collections", "branches"
  add_foreign_key "membership_payment_collections", "centers"
  add_foreign_key "membership_payment_records", "members"
  add_foreign_key "messages", "members"
  add_foreign_key "messages", "messages"
  add_foreign_key "messages", "users"
  add_foreign_key "monthly_accounting_code_summaries", "accounting_codes"
  add_foreign_key "monthly_accounting_code_summaries", "branches"
  add_foreign_key "monthly_closing_collections", "branches"
  add_foreign_key "online_application_documents", "online_applications"
  add_foreign_key "online_applications", "branches"
  add_foreign_key "online_applications", "centers"
  add_foreign_key "online_applications", "membership_arrangements"
  add_foreign_key "online_applications", "membership_types"
  add_foreign_key "project_types", "project_type_categories"
  add_foreign_key "savings_insurance_transfer_collections", "branches"
  add_foreign_key "savings_insurance_transfer_collections", "centers"
  add_foreign_key "survey_answers", "surveys"
  add_foreign_key "survey_questions", "surveys"
  add_foreign_key "time_deposit_collections", "branches"
  add_foreign_key "time_deposit_collections", "centers"
  add_foreign_key "transfer_savings_records", "branches"
  add_foreign_key "transfer_savings_records", "centers"
  add_foreign_key "user_demerits", "branches"
  add_foreign_key "user_demerits", "users"
  add_foreign_key "user_tasks", "users"
  add_foreign_key "withdrawal_collections", "branches"
  add_foreign_key "withdrawal_collections", "centers"
end
