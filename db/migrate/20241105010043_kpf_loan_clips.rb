class KpfLoanClips < ActiveRecord::Migration[7.1]
  def change
     create_table :kpf_loan_clips, id: :uuid do |t|
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
  end
end
