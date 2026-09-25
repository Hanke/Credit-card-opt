module Recommendations
  class PurchaseParams
    include ActiveModel::Model
    include ActiveModel::Attributes

    MAX_AMOUNT = 1_000_000

    attribute :amount, :decimal
    attribute :category, :string
    attribute :user_card_ids

    validates :amount, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: MAX_AMOUNT, allow_blank: true }
    validates :category, presence: true
    validates :category, inclusion: { in: PurchaseCategories::ALL, message: "is not a supported purchase category" }, allow_blank: true
    validate :user_card_ids_are_whole_numbers

    def amount_before_type_cast
      @attributes["amount"].value_before_type_cast
    end

    def user_card_ids
      return if super.blank?

      Array(super).map { |id| Integer(id.to_s, 10, exception: false) }
    end

    private

    def user_card_ids_are_whole_numbers
      errors.add(:user_card_ids, "must be whole numbers") if user_card_ids&.include?(nil)
    end
  end
end
