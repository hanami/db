# frozen_string_literal: true

module Hanami
  module DB
    # @api public
    # @since 2.2.0
    class Struct < ROM::Struct

      def to_json
        to_h.to_json
      end
    end
  end
end
