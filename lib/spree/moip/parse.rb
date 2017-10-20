module Spree::Moip
  class Parse
    def self.order(options)
      {
        own_id: options.order_id,
        items: items(options),
        amount: amount(options),
        customer: customer(options)
      }
    end

    def self.items(options)
      options.line_items.map do |item|
        {
          product: item[:name],
          quantity: item[:quantity],
          price: item[:price].to_i
        }
      end
    end

    def self.amount(options)
      {
        currency: options.currency,
        subtotals: {
          shipping: options.shipping.to_i,
          addition: options.tax.to_i,
          discount: options.discount.to_i
        }
      }
    end

    def self.customer(options)
      data = options.moip_address
      {
        own_id: options.customer_id || options.guest_token,
        fullname: data[:full_name],
        email: options.email,
        tax_document: {
          type: data[:tax_document_type],
          number: data[:tax_document].gsub(/[^\d]/, '')
        },
        phone: phone(options),
        shipping_address: address(options)
      }
    end

    def self.address(options)
      options.moip_address.extract!(
        :street,
        :street_number,
        :complement,
        :district,
        :city,
        :state,
        :country,
        :zip_code
      )
    end

    def self.phone(options)
      phone = options.moip_address[:phone]
      country = '\+(\d){2}'
      area    = '\((\d){2}\)'
      number  = '(\d){4,5}-(\d){4,5}'
      pattern = /(?<country>#{country})?(?<area>#{area})(?<number>#{number})/
      match = phone.match(pattern)
      raise 'Invalid phone number' unless match
      {
        country_code: match[:country] || '55',
        area_code: match[:area].gsub(/[^\d]/, ''),
        number: match[:number].gsub(/[^\d]/, '')
      }
    end
  end
end
