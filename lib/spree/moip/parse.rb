module Spree
  class Moip::Parse
    class << self
      def payment(options, source:)
        {
          installment_count: 1,
          funding_instrument: {
            method: 'CREDIT_CARD',
            credit_card: credit_card(options, source: source)
          }
        }
      end

      def credit_card(_, source:)
        data = {
          holder: {
            fullname: source.name,
            birthdate: source.birth_date.strftime('%Y-%m-%d'),
            tax_document: tax_document(source)
          }
        }
        if source.gateway_payment_profile_id.present?
          data.merge(id: source.gateway_payment_profile_id)
        elsif source.encrypted_data.present?
          data.merge(hash: source.encrypted_data)
        else
          data.merge(
            number: source.number,
            expiration_month: source.month,
            expiration_year: source.year,
            cvc: source.verification_value
          )
        end
      end

      def order(options, customer_id: nil)
        {
          own_id: options.order_id,
          items: items(options),
          amount: amount(options),
          customer: customer_id ? { id: customer_id } : customer(options)
        }
      end

      def items(options)
        options.line_items.map do |item|
          {
            product: item[:name],
            quantity: item[:quantity],
            price: item[:price].to_i
          }
        end
      end

      def amount(options)
        {
          currency: options.currency,
          subtotals: {
            shipping: options.shipping.to_i,
            addition: options.tax.to_i,
            discount: options.discount.to_i
          }
        }
      end

      def customer(options)
        data = options.moip_address
        {
          own_id: options.customer_id || options.guest_token,
          fullname: data[:full_name],
          email: options.email,
          tax_document: tax_document(options),
          phone: phone(options),
          shipping_address: address(options)
        }
      end

      def address(options)
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

      def phone(options)
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

      private

      def tax_document(data)
        {
          type: data.tax_document_type.to_s.upcase,
          number: data.tax_document.gsub(/[^\d]/, '')
        }
      end
    end
  end
end
