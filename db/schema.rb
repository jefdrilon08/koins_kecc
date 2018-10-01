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

ActiveRecord::Schema.define(version: 2018_09_30_114105) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

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
    t.index ["branch_id"], name: "index_accounting_entries_on_branch_id"
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

  create_table "branches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "cluster_id"
    t.string "name"
    t.string "short_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cluster_id"], name: "index_branches_on_cluster_id"
  end

  create_table "centers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "branch_id"
    t.string "name"
    t.string "short_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_centers_on_branch_id"
  end

  create_table "clusters", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "area_id"
    t.string "name"
    t.string "short_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id"], name: "index_clusters_on_area_id"
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
    t.index ["branch_id"], name: "index_loans_on_branch_id"
    t.index ["center_id"], name: "index_loans_on_center_id"
    t.index ["loan_product_id"], name: "index_loans_on_loan_product_id"
    t.index ["member_id"], name: "index_loans_on_member_id"
    t.index ["project_type_id"], name: "index_loans_on_project_type_id"
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
    t.index ["branch_id"], name: "index_members_on_branch_id"
    t.index ["center_id"], name: "index_members_on_center_id"
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

  add_foreign_key "accounting_entries", "branches"
  add_foreign_key "branches", "clusters"
  add_foreign_key "centers", "branches"
  add_foreign_key "clusters", "areas"
  add_foreign_key "journal_entries", "accounting_codes"
  add_foreign_key "journal_entries", "accounting_entries"
  add_foreign_key "loans", "branches"
  add_foreign_key "loans", "centers"
  add_foreign_key "loans", "loan_products"
  add_foreign_key "loans", "members"
  add_foreign_key "loans", "project_types"
  add_foreign_key "members", "branches"
  add_foreign_key "members", "centers"
  add_foreign_key "project_types", "project_type_categories"
end
