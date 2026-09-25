class ApplicationSerializer
  def self.call(record)
    new(record).call
  end

  def self.collection(records)
    records.map { |record| call(record) }
  end

  def initialize(record)
    @record = record
  end

  private

  attr_reader :record
end
