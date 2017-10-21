module Spree
  class Gateway::MoipCredit < Gateway
    preference :token, :string
    preference :key, :string

    def provider_class
      Spree::Moip
    end
  end
end
