module ServiceResult
  def self.with(*fields)
    Struct.new(*fields, :errors, keyword_init: true) do
      def self.success(**payload)
        new(**payload, errors: [])
      end

      def self.failure(errors)
        new(errors: Array(errors))
      end

      def success? = errors.empty?
    end
  end
end
