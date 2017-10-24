FactoryGirl.modify do
  factory :credit_card do
    number '4012001037141112'
    verification_value '123'
    month 5
    year 2018
    tax_document '678.224.121-83'
    birth_date '01-01-1990'
  end
end
