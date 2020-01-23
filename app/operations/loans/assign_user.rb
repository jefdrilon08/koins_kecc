module Loans
  class AssignUser
    def initialize(config: {})
      @config = config
      @branch = @config[:branch]
    end

    def execute!
      sets    = [] 
      result  = ActiveRecord::Base.connection.execute(<<-EOS).to_a
                  SELECT
                    loans.id,
                    centers.id AS center_id,
                    centers.name AS center_name,
                    users.id AS user_id
                  FROM
                    loans
                  INNER JOIN
                    centers ON centers.id = loans.center_id
                  INNER JOIN
                    users ON users.id = centers.user_id
                  WHERE
                    loans.user_id IS NULL AND loans.branch_id = '#{@branch.id}'
                EOS

      sets  = result.map{ |o|
                "('#{o.fetch('id')}', '#{o.fetch('user_id')}')"
              }.join(",")

      if sets.present?
        query = "
          UPDATE loans AS l SET
            user_id = temp.user_id::uuid
          FROM (values
            #{sets}
          ) AS temp(id, user_id)
          WHERE temp.id = l.id::text
        "

        ActiveRecord::Base.connection.execute(query)
      end
    end
  end
end
