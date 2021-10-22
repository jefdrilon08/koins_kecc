module Reports
  class GenerateAddressUpdate
    def initialize(branch_id:)
      @branch_id = branch_id
    
      @data =  { 
                  records: [] 
               }
    end

    def execute!
      query!
      @data[:records] = @result.map{ |o|
                                  temp = {
                                    id_number: o.fetch("id_number"),
                                    member_id: o.fetch("member_id"),
                                    last_name: o.fetch("last_name"),
                                    first_name: o.fetch("first_name"),
                                    middle_name: o.fetch("middle_name"),
                                    center_name: o.fetch("center_name"),
                                    date_of_membership: o.fetch("date_of_membership"),
                                    status: o.fetch("status"),
                                    city: o.fetch("city"),
                                    brgy: o.fetch("brgy")
                                  }
                      }
      @data

    end


    def query!
      @result = ActiveRecord::Base.connection.execute(<<-EOS).to_a
                  Select 
                    m.id AS member_id,
                    m.identification_number AS id_number,
                    m.last_name as last_name,
                    m.first_name as first_name,
                    m.middle_name,
                    m.data->'address'->'city' AS city,
                    m.data->'address'->'district' AS brgy,
                    c.name as center_name,
                    mpr.date_paid as date_of_membership,
                    m.status as status
                  from 
                    members m
                  inner join
                    centers c on c.id = m.center_id
                  inner join
                    membership_payment_records mpr on mpr.member_id = m.id
                  where 
                    m.branch_id = '#{@branch_id}' and 
                    m.status != 'archived' and
                    m.data->'address'->'region' IS NULL and
                    mpr.membership_name = 'K-KOOP'
                  ORDER BY
                    mpr.date_paid,
                    m.last_name
                EOS

    end
  end
end
