module Cards
  class Search
    MAX_RESULTS = 200

    def self.call(query: nil)
      new(query: query).call
    end

    def initialize(query: nil)
      @query = query
    end

    def call
      CreditCard
        .active
        .search(query)
        .includes(:reward_currency)
        .order(:issuer, :name)
        .limit(MAX_RESULTS)
    end

    private

    attr_reader :query
  end
end
