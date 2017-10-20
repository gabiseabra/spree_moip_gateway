module Spree
  Payment::GatewayOptions.class_eval do
    def guest_token
      order.guest_token
    end

    def tax_document_type
      order.tax_tocument_type.to_s.upcase
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
  end
end
