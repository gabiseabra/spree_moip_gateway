FactoryGirl.modify do
  factory :order do
    email 'spree@example.com'
    tax_document_type :cpf
    tax_document '678.224.121-83'
  end
end
