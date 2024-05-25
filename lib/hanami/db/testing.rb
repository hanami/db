# frozen_string_literal: true

require "uri"

module Hanami
  module DB
    module Testing
      # Replaces development suffix in test mode
      #
      # @api private
      # @since 2.2.0
      DATABASE_NAME_SUFFIX = "_test"

      # @api private
      # @since 2.2.0
      DATABASE_NAME_MATCHER = /_dev(elopment)?$/
      private_constant :DATABASE_NAME_MATCHER

      # @api private
      # @since 2.2.0
      def self.database_url(url)
        url = URI(url.to_s)

        if url.path =~ DATABASE_NAME_MATCHER
          url.path = url.path.sub(DATABASE_NAME_MATCHER, DATABASE_NAME_SUFFIX)
        elsif !url.path.end_with?(DATABASE_NAME_SUFFIX)
          url.path << DATABASE_NAME_SUFFIX
        end

        url.to_s
      end
    end
  end
end
