class AddIndexForLoanAmortizationScheduleEntryAmounts < ActiveRecord::Migration[5.2]
  def change
    add_index(
      :amortization_schedule_entries,
      [:loan_id, :due_date],
      name: 'idx_amortization_schedule_entries_loans_principal_interest',
      where: "(interest > 0 AND principal > 0)"
    )
  end
end
