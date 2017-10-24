Spree::PermittedAttributes.address_attributes.push(
  :street_number,
  :complement,
  :district
)

Spree::PermittedAttributes.user_attributes.push(
  :tax_document_type,
  :tax_document
)

Spree::PermittedAttributes.checkout_attributes.push(
  :tax_document_type,
  :tax_document
)

Spree::PermittedAttributes.source_attributes.push(
  :tax_document,
  :birth_date
)
