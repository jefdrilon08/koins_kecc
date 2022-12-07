module Reports
  class GenerateGovernmentIdentificationNumbers
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
                                    sss_number:         o.fetch("sss_number"),
                                    pag_ibig_number:    o.fetch("pag_ibig_number"),
                                    phil_health_number: o.fetch("phil_health_number"),
                                    tin_number:         o.fetch("tin_number").to_s,
                                    share_capital_balance:      o.fetch("share_capital_balance")
                              
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
                    m.data->'government_identification_numbers'->'sss_number' AS sss_number,
                    m.data->'government_identification_numbers'->'pag_ibig_number' AS pag_ibig_number,
                    m.data->'government_identification_numbers'->'phil_health_number' AS phil_health_number,
                    m.data->'government_identification_numbers'->'tin_number' AS tin_number,
                    c.name as center_name,
                    ma.balance as share_capital_balance
                  from 
                    members m
                  inner join
                    centers c on c.id = m.center_id
                  inner join
                    member_accounts ma on ma.member_id =  m.id
                  where 
                    m.branch_id = '#{@branch_id}' and 
                    m.status = 'active' and
                    ma.account_subtype = 'Share Capital'
                  ORDER BY
                    m.last_name
                EOS

    end
  end
end
