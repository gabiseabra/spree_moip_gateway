module Spree
  class Moip::Parse
    class << self
      def payment(options, source:)
        {
          installment_count: 1,
          funding_instrument: credit_card(source, store: false)
        }
      end

      def credit_card(source, store: false)
        data = {
          holder: {
            fullname: source.name,
            birthdate: source.birth_date.strftime('%Y-%m-%d'),
            tax_document: {
              type: 'CPF',
              number: source.tax_document.gsub(/[^\d]/, '')
            }
          }
        }
        if source.gateway_payment_profile_id.present?
          data.merge!(
            id: source.gateway_payment_profile_id,
            first6: source.first_digits,
            last4: source.last_digits,
            brand: source.moip_brand
          )
        elsif source.encrypted_data.present?
          data.merge!(hash: source.encrypted_data, sotre: store)
        else
          data.merge!(
            store: store,
            number: source.number,
            expiration_month: source.month,
            expiration_year: source.year,
            cvc: source.verification_value
          )
        end
        { method: 'CREDIT_CARD', credit_card: data }
      end

      def order(options, customer_id: nil)
        {
          own_id: options[:order_id],
          items: order_items(options),
          amount: order_amount(options),
          customer: customer_id ? { id: customer_id } : order_customer(options)
        }
      end

      def customer(user, token:)
        {
          own_id: token || user.id,
          fullname: user.shipping_address.full_name,
          email: user.email,
          tax_document: {
            type: user.tax_document_type.to_s.upcase,
            number: user.tax_document
          },
          phone: phone(user.shipping_address.phone),
          shipping_address: address(user.shipping_address.moip_hash)
        }
      end

      private

      def order_customer(options)
        data = options[:moip_address]
        {
          own_id: options[:customer_id] || options[:guest_token],
          fullname: data[:full_name],
          email: options[:email],
          tax_document: {
            type: options[:tax_document_type].to_s.upcase,
            number: options[:tax_document].gsub(/[^\d]/, '')
          },
          phone: phone(options[:moip_address][:phone]),
          shipping_address: address(options[:moip_address])
        }
      end

      def order_items(options)
        options[:line_items].map do |item|
          {
            product: item[:name],
            quantity: item[:quantity],
            price: item[:price].to_i
          }
        end
      end

      def order_amount(options)
        {
          currency: options[:currency],
          subtotals: {
            shipping: options[:shipping].to_i,
            addition: options[:tax].to_i,
            discount: options[:discount].to_i
          }
        }
      end

      def address(moip_address)
        moip_address.extract!(
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

      def phone(phone)
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
end
