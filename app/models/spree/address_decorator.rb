require 'validates_cpf_cnpj'

module Spree
  Address.class_eval do
    validates :street_number,
              :district,
              presence: true
    validates :phone,
              presence: true,
              format: { with: /\A(\+(\d){2})?\((\d){2}\)(\d){4,5}-(\d){4,5}\z/ }

    def moip_hash
      {
        full_name: full_name,
        street: address1,
        street_number: street_number,
        complement: complement,
        district: district,
        city: city,
        zip_code: zipcode,
        state: state_text,
        country: country.try(:iso3),
        phone: phone
      }
    end
  end
end
