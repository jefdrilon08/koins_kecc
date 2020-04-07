module Insurance
  class FetchWithdrawalCollectionForHiip
    def execute!
      withdrawal_collection_ids = WithdrawalCollection.find_by_sql(<<-SQL)
        SELECT wc.id
        FROM withdrawal_collections AS wc
        INNER JOIN accounting_entries AS ae
          ON ae.book              = wc.data->'accounting_entry'->>'book'
          AND ae.reference_number = wc.data->'accounting_entry'->>'reference_number'
          AND ae.particular       = wc.data->'accounting_entry'->>'particular'
        INNER JOIN journal_entries AS je
          ON je.accounting_entry_id = ae.id
          AND je.accounting_code_id = '84c56c8d-803c-4a30-9720-ad90c4e30abc'
        WHERE wc.status = 'approved'
          AND lower(wc.data->'accounting_entry'->>'particular') LIKE '%hiip%'
        GROUP BY wc.id
      SQL

      WithdrawalCollection.where(id: withdrawal_collection_ids)
    end
  end
end