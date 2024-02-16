class ModifyJournalEntryDatePosted < ActiveRecord::Migration[6.1]
  def change
    remove_column :journal_entries, :date_posted
    add_column :journal_entries, :ae_date_posted, :date
  end
end
