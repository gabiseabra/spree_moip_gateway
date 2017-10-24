module Spree
  Payment::GatewayOptions.class_eval do
    alias_method :original_hash_methods, :hash_methods

    def payment_id
      @payment.id
    end

    def guest_token
      order.guest_token
    end

    def tax_document_type
      order.tax_document_type
    end

    def tax_document
      order.tax_document
    end

    def line_items
      order.line_items.map do |item|
        {
          name: item.name,
          quantity: item.quantity,
          price: item.price * exchange_multiplier
        }
      end
    end

    def moip_address
      order.billing_address.try(:moip_hash)
    end

    def hash_methods
      original_hash_methods + %i[
        payment_id
        guest_token
        moip_address
        line_items
        tax_document_type tax_document
      ]
    end
  end
end
