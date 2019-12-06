class SoaFundsController < ApplicationController
  def turkey
    @subtypes = MemberAccount
    .pluck(:account_subtype).uniq
    .map { |subtype| [subtype.parameterize.underscore, subtype] }
    .to_h
    sums = @subtypes.map do |key, subtype|
    <<-EOS
    SUM(CASE WHEN account_subtype = '#{subtype}' AND transaction_type = 'withdraw' THEN amount ELSE 0 END) OVER(PARTITION BY member_id ORDER BY transacted_at) AS #{key}_debit,
    SUM(CASE WHEN account_subtype = '#{subtype}' AND transaction_type = 'deposit' THEN amount ELSE 0 END) OVER(PARTITION BY member_id ORDER BY transacted_at) AS #{key}_credit,
    EOS
    end

    @rows = ActiveRecord::Base.connection.execute(<<-EOS).to_a
    SELECT
    account_type,
    account_subtype,
    members.id as member_id,
    members.last_name,
    members.first_name,
    #{sums.join}
    transaction_type,
    amount,
    transacted_at
    FROM 
    account_transactions 
    INNER JOIN member_accounts ON member_accounts.id = account_transactions.subsidiary_id 
    INNER JOIN members ON members.id = member_accounts.member_id 
    WHERE transacted_at BETWEEN '2019-11-07' AND '2020-02-15'
    AND members.branch_id = '18cebed1-4838-4335-9023-ffd35c5e2629'
    AND members.status IN ('active', 'resigned')
    ORDER BY
    last_name ASC, first_name ASC, transacted_at DESC, account_type ASC, account_subtype ASC
    LIMIT 100
    EOS
  end
end
