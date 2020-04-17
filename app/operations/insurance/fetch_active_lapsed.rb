module Insurance
  class FetchActiveLapsed
    attr_accessor :data
    def initialize(branches:)
      @branches = branches
    end

    def execute!
      member_ids = Member.where(branch_id: @branches.pluck(:id)).find_by_sql(<<-SQL)
        SELECT m.id
        FROM members AS m
        WHERE m.status = 'active'
          AND m.insurance_status = 'lapsed'
        GROUP BY m.id
      SQL

      Member.includes(:branch, :center).where(id: member_ids)
    end
  end
end