module Insurance
  class FetchMembersForReinsurance
    def execute!
      member_ids = Member.find_by_sql(<<-SQL)
        SELECT m.id
        FROM members AS m
        INNER JOIN loans AS l
          ON l.member_id = m.id
        INNER JOIN accounting_entries AS ae
          ON ae.book              = l.data->'accounting_entry'->>'book'
          AND ae.reference_number = l.data->'accounting_entry'->>'reference_number'
          AND ae.particular       = l.data->'accounting_entry'->>'particular'
        INNER JOIN journal_entries AS je
          ON je.accounting_entry_id = ae.id
          AND je.accounting_code_id = '#{CLIP_ACCOUNTING_CODE_ID}'
          AND je.amount > 0        
        WHERE m.status = 'active'
          AND l.status = 'active'
        GROUP BY m.id
        HAVING SUM(l.principal) > 200000
      SQL

      Member.includes(:branch, :center).where(id: member_ids)
    end
  end
end
