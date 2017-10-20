FactoryGirl.modify do
  factory :user do
    tax_document_type :cpf
    tax_document '678.224.121-83'
  end
end
