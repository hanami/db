# frozen_string_literal: true

require "pathname"
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

      class << self
        # @api private
        # @since 2.2.0
        def database_url(url)
          # URI#dup does not duplicate internal instance
          # variables, making mutation dangerous.
          url = URI(url.to_s)

          case deconstruct_url(url)
          in {scheme: "sqlite", opaque: nil, path:} unless path.nil?
            url.path = database_filename(path)
          in {path: String => path} if path =~ DATABASE_NAME_MATCHER
            url.path = path.sub(DATABASE_NAME_MATCHER, DATABASE_NAME_SUFFIX)
          in {path: String => path} unless path.end_with?(DATABASE_NAME_SUFFIX)
            url.path << DATABASE_NAME_SUFFIX
          else
            # do nothing
          end

          url.to_s
        end

        private

        # Deconstructs a URI::Generic for pattern-matching.
        #
        # @param url [URI] Database URL parsed as URI::Generic
        #
        # @return [Hash]
        #
        # @api private
        # @since 2.2.0
        def deconstruct_url(url)
          %i[opaque path scheme].each_with_object({}) do |part, hash|
            hash[part] = url.public_send(part)
          end
        end

        # Transform filename as with URI paths, but account for extname
        #
        # @param path [String] path component from URI
        #
        # @return [String]
        #
        # @api private
        # @since 2.2.0
        def database_filename(path)
          path = Pathname(path)
          ext = path.extname
          database = path.basename(ext).to_s

          if database =~ /^dev(elopment)?$/
            database = "test"
          elsif database =~ DATABASE_NAME_MATCHER
            database.sub!(DATABASE_NAME_MATCHER, DATABASE_NAME_SUFFIX)
          elsif !database.end_with?(DATABASE_NAME_SUFFIX)
            database << DATABASE_NAME_SUFFIX
          end

          path.dirname.join(database + ext).to_s
        end
      end
    end
  end
end
