class AddBookAndBranchAndAccountingFundAndStatusAndDatePostedAndDatePreparedToJournalEntries < ActiveRecord::Migration[6.1]
  def change
    add_column :journal_entries, :book, :string
    add_reference :journal_entries, :branch, foreign_key: true, type: :uuid
    add_reference :journal_entries, :accounting_fund, foreign_key: true, type: :uuid
    add_column :journal_entries, :status, :string
    add_column :journal_entries, :date_posted, :date
    add_column :journal_entries, :date_prepared, :date
  end
end
