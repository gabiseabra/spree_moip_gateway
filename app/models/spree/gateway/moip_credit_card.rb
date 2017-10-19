module Spree
  class Gateway::MoipCreditCard < Gateway
    preference :token, :string
    preference :key, :string

    def provider_class
      Spree::Moip::Client
    end
  end
end
