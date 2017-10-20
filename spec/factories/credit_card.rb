FactoryGirl.modify do
  factory :credit_card do
    tax_document_type :cpf
    tax_document '678.224.121-83'
    birth_date '01-01-1990'
  end
end
