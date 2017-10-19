FactoryGirl.modify do
  factory :address do
    address1 'Avenida Faria Lima'
    address2 ''
    street_number 100
    district 'Itaim'
    city 'São Paulo'
    zipcode '01452-001'
    phone '(21)0000-0000'
    tax_document_type :cpf
    tax_document '678.224.121-83'
  end
end
