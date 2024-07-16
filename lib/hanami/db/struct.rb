# frozen_string_literal: true

module Hanami
  module DB
    # @api public
    # @since 2.2.0
    class Struct < ROM::Struct
      # @api public
      # @since 2.2.0
      #
      # Simple conversion of attributes to JSON format, without this method, the instance of the struct gets converted to a string
      def to_json
        to_h.to_json
      end
    end
  end
end
