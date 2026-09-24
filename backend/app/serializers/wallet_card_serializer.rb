class WalletCardSerializer < ApplicationSerializer
  def call
    CreditCardSerializer.call(record.credit_card).merge(
      active: record.credit_card.active,
      added_at: record.added_at.iso8601
    )
  end
end
