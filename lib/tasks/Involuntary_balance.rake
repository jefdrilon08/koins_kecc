branch_id = '08d69d87-566c-444c-9042-bc1c495a7e3d'
members = Member.where(branch_id: branch_id, status: 'resigned')

branch_name = Branch.find(branch_id).name

loan_product_names = {
  '4e517b79-5ee7-48f3-92ad-b6fb1a3c0a00' => 'K - KABUHAYAN W1',
  '7cd86218-60b1-4836-ad4c-d2432bf26d8e' => 'K - EDUKASYON',
  '7d33c3b0-a683-4e4e-8017-929c171e43e4' => 'K - EDUKASYON W2',
  '584b2b6d-0499-4564-8c9b-57e2407b08b0' => 'K - BAHAY W1',
  '204f8e78-586a-4266-ba9d-901b2f90d3c5' => 'K - BAHAY W2',
  'e60d4d70-0875-4d48-b6b1-40e813242df4' => 'K - BAHAY W3',
  'edf1be2e-ff70-4ccb-afb3-0bf6ec700204' => 'K - KALUSUGAN W1',
  '6b967738-dc57-467d-a51b-7a77de62468f' => 'K - KALUSUGAN W2',
  '22f9d132-820f-4c3d-830e-aaee1c0b206c' => 'K - KALUSUGAN W3',
  '8b1b3103-2e3b-4308-bc76-cf5fec772f2e' => 'K - KALUSUGAN W4',
  'ae07e628-b99a-4a4a-a798-252446d59df9' => 'K - KALUSUGAN W5',
  '7813ee07-2666-4936-830b-611ac0cb626c' => 'K - KALUSUGAN W6',
  '091a5859-021a-4b98-8751-19ec08ade079' => 'K - KALUSUGAN W7',
  'b9535f97-c423-458a-849a-dd9a3e0b56bc' => 'K - BENEPISYO W1',
  '29a8e8a4-56f5-4aeb-ad49-0b0cd1bcda0a' => 'K - BENEPISYO W2',
  '1d383a11-1dae-40ac-8932-b55fc0d36515' => 'K - NHA W1',
  '160f1650-0b0d-4dcc-bb5e-eb834fd0b3cb' => 'K - NHA W2',
  '4e585cde-cc08-4b3b-b42f-b9a5a90f9b47' => 'K - EDUKASYON W3',
  'eb2908ee-5b98-4730-889d-8cfceb007cc1' => 'K - Noche Buena',
  '8614b439-f27a-4853-b41d-e601889bbe4c' => 'K - BISIKLETA',
  '61c7b2c2-7571-4fc9-a214-9f1a6564f111' => 'ALALAY SA K (Business Disruption Loan)',
  '2696cbe4-2c8f-478b-89d5-df8eefa46c13' => 'ALALAY SA K W2',
  '50e2a941-d7c2-470d-8e70-26ffdfd5f0bc' => 'GREEnS Loan',
  '444ed2de-5286-4ed5-a191-c2cef1b888d0' => 'K - Agapay',
  'c77fa8f0-aa0f-4883-a677-e4addedf7ca3' => 'K - BAHAY (Makita Power Tools)',
  '6ef096d0-cd2c-4e10-b667-abb502ec894e' => 'K - BENEPISYO',
  '806593d3-4ac4-4f58-bc83-76230aca4039' => 'K - BENEPISYO W3',
  '9bd1f80b-370c-48f6-8b82-7294fd317a25' => 'K - BENEPISYO W4',
  'e5df6de5-9ee8-4771-a98e-f2a2386bd154' => 'K - CIL',
  '73dfd935-a2a5-4ff2-b3e0-5fa252c85d74' => 'K - EDUKASYON W4',
  'c18f7606-8af0-41f2-a5b2-06d6439777d1' => 'K - KABUHAYAN W2',
  '993f9d01-fc46-4331-8f02-c4254d6d9dbb' => 'K - KABUHAYAN W3',
  '43e1ae2f-b723-4646-816c-5659146cf2ad' => 'K - KABUHAYAN W4',
  'ff602b57-fe94-4510-b8ff-c0c3e3813c88' => 'K - KALAMIDAD',
  '81cd42d2-9ea8-4c54-824b-3d4cd9f6efe2' => 'K - KALUSUGAN W8',
  '9b9ee937-88ec-4332-98fb-b35c677079a5' => 'K - KALUSUGAN W9',
  '52a44657-62fb-441e-b844-b77d59f5c4ca' => 'K - KASAL',
  'da9b8bc1-8b9b-4e47-b753-9ae4edd0e6e1' => 'K - KASANGKAPAN',
  '1830bd55-6629-46ab-8a39-665840c7962f' => 'K - MAGGAGAWA',
  'cc31d1f6-b448-4bf4-854b-41cb08efacdc' => 'K - MOTORSIKLO',
  '90b84b35-b5c3-4b58-8040-55bf7c8be5c5' => 'K - PWD',
  '1c2fcdbd-d60b-402c-b04b-824bb90958d1' => 'K - SAGIP',
  'feef6e81-1644-4615-b795-965834517c8f' => 'K - TODA',
  '0093eb80-ec9d-45e1-9f80-73e678fea145' => 'K - TRABAHO',
  '709c3812-da61-4e4d-9000-20e153dab975' => 'K - TRANSPORTASYON',
  'd1fe60f9-380f-4f2a-9b44-23747b9d7d1e' => 'K - YAKAP'
}

if members.any?
  member_ids = members.pluck(:id)


  loan_balances = {}


  total_principal_sum = 0
  total_interest_sum = 0


  loan_product_names.keys.each do |product_id|

    total_principal_balance = Loan.where(member_id: member_ids, loan_product_id: product_id, status: 'active').sum(:principal_balance)
    total_interest_balance = Loan.where(member_id: member_ids, loan_product_id: product_id, status: 'active').sum(:interest_balance)


    loan_balances[product_id] = {
      total_principal_balance: total_principal_balance,
      total_interest_balance: total_interest_balance
    }


    total_principal_sum += total_principal_balance
    total_interest_sum += total_interest_balance
  end

	 puts "#{branch_name}"
	 
	 
  loan_balances.each do |product_id, balances|
    loan_name = loan_product_names[product_id]
    puts "#{loan_name}"
    puts "  Total Principal Balance: #{balances[:total_principal_balance]}"
    puts "  Total Interest Balance: #{balances[:total_interest_balance]}"
  end

  puts "Overall Total Principal Balance: #{total_principal_sum.round(2)}"
  puts "Overall Total Interest Balance: #{total_interest_sum.round(2)}"
else
  puts "No members found with status 'resigned' in the specified branch."
end