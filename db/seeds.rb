# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create!(
  [
    {
      first_name: "Admin",
      last_name: "Demo",
      username: "admin",
      email: "admin@koins.com",
      password: "password",
      password_confirmation: "password",
      identification_number: "111111"
    }
  ]
)

1..100.times do |i|
  AccountingCode.create!(
    code: "ASSETS-#{i}",
    name: "ASSETS-#{i}",
    category: "ASSETS"
  )

  AccountingCode.create!(
    code: "LIABILITIES-#{i}",
    name: "LIABILITIES-#{i}",
    category: "LIABILITIES"
  )

  AccountingCode.create!(
    code: "EQUITIES-#{i}",
    name: "EQUITIES-#{i}",
    category: "EQUITIES"
  )

  AccountingCode.create!(
    code: "EXPENSES-#{i}",
    name: "EXPENSES-#{i}",
    category: "EXPENSES"
  )

  AccountingCode.create!(
    code: "INCOME-#{i}",
    name: "INCOME-#{i}",
    category: "INCOME"
  )
end
