# Canonical list of purchase categories used by reward rules and the API.
module PurchaseCategories
  ALL = %w[groceries dining gas travel hotels flights transit entertainment drugstore general other].freeze

  def self.valid?(category)
    ALL.include?(category.to_s)
  end
end
