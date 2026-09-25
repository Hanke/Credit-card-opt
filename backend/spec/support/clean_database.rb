INTERNAL_TABLES = %w[schema_migrations ar_internal_metadata].freeze

RSpec.configure do |config|
  config.before(:suite) do
    connection = ActiveRecord::Base.connection
    connection.truncate_tables(*(connection.tables - INTERNAL_TABLES))
  end
end
