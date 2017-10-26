class Spree::MoipTransaction < Spree::Base
  belongs_to :payment
  has_one :order, through: :payment
  has_one :payment_method, through: :payment

  scope :in_state, ->(state) { where(state: state) }
  scope :not_in_state, ->(state) { where.not(state: state) }

  STATES = %w[CREATED WAITING IN_ANALYSIS PRE_AUTHORIZED
              AUTHORIZED CANCELLED REFUNDED REVERSED SETTLED].freeze
  FINAL_STATES = %w[AUTHORIZED CANCELLED REFUNDED REVERSED SETTLED].freeze
  PROCESSING_STATES = (STATES - FINAL_STATES).freeze

  def self.fetch_updates
    updated = 0
    in_state(PROCESSING_STATES).each do |transaction|
      updated += 1 if transaction.fetch_updates
    end
    updated
  end

  def can_capture?
    state == 'PRE_AUTHORIZED'
  end

  def can_void?
    %w[AUTHORIZED PRE_AUTHORIZED SETTLED].include?(state)
  end

  def actions
    %w[capture void].select do |action|
      !respond_to?("can_#{action}?") || send("can_#{action}?")
    end
  end

  def fetch_updates
    parse_response payment_method.api.payment.show(transaction_id)
  end

  def parse_update(response)
    begin
      updated_at = DateTime.parse(response.updated_at)
      if response.status != state && moip_updated_at < updated_at
        self.state = response.status
        self.moip_updated_at = updated_at
        payment.update(state: to_spree_state) if payment.state != to_spree_state
        save
        true
      end
    rescue StandardError => e
      logger.error(Spree.t('moip.failed_to_update'))
      logger.error(" #{e.to_yaml}")
    end
    false
  end

  def to_spree_state
    case state
    when 'CREATED' then 'checkout'
    when 'WAITING', 'IN_ANALYSIS', 'PRE_AUTHORIZED' then 'pending'
    when 'CANCELLED' then 'failed'
    when 'REFUNDED', 'REVERSED' then 'void'
    when 'AUTHORIZED', 'SETTLED' then 'completed'
    end
  end
end
