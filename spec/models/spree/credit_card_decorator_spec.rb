require 'spec_helper'

describe Spree::CreditCard, moip: { type: :credit }, vcr: { cassette_name: 'credit_card_decorator' } do
  before(:each) { complete_order! }

  CAPTURABLE_STATES = %w[PRE_AUTHORIZED]
  VOIDABLE_STATES = %w[AUTHORIZED PRE_AUTHORIZED SETTLED]

  def fail_message(action, state, should_work)
    expectation = (should_work ? 'Expected' : 'Didn\'t expect')
    expectation + "to #{action} #{state}"
  end

  describe '#can_capture?' do
    it "can capture when miop transaction is #{CAPTURABLE_STATES}" do
      Spree::MoipTransaction::STATES.each do |state|
        should_work = CAPTURABLE_STATES.include?(state)
        payment.moip_transaction.state = state
        expect(payment_source.can_capture?(payment)).to(
          be(should_work),
          fail_message('capture', state, should_work)
        )
      end
    end
  end

  describe '#can_void?' do
    it "can void when miop transaction state is #{VOIDABLE_STATES}" do
      Spree::MoipTransaction::STATES.each do |state|
        should_work = VOIDABLE_STATES.include?(state)
        payment.moip_transaction.state = state
        expect(payment_source.can_void?(payment)).to(
          be(should_work),
          fail_message('void', state, should_work)
        )
      end
    end
  end
end
