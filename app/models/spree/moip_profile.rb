class Spree::MoipProfile < Spree::Base
  enum tax_document_type: %i[cpf cnpj]

  belongs_to :user
  belongs_to :payment_method, polymorphic: true
  has_many :credit_cards,
           foreign_key: :gateway_customer_profile_id,
           primary_key: :moip_id

  has_secure_token

  before_create :register_customer

  private

  def register_customer
    response = payment_method.create_customer(user, token: token)
    self.moip_id = response.id
    self.tax_document_type = user.tax_document_type
    self.tax_document = user.tax_document
  end
end
