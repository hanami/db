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
          url = parse_url(url)

          case deconstruct_url(url)
          in { scheme: "sqlite", opaque: nil, path: } unless path.nil?
            url.path = database_filename(path)
          in { path: String => path } if path =~ DATABASE_NAME_MATCHER
            url.path = path.sub(DATABASE_NAME_MATCHER, DATABASE_NAME_SUFFIX)
          in { path: String => path } unless path.end_with?(DATABASE_NAME_SUFFIX)
            url.path << DATABASE_NAME_SUFFIX
          else
            # do nothing
          end

          stringify_url(url)
        end

        private

        # @api private
        # @since 2.2.0
        def parse_url(url)
          if url.is_a?(URI::Generic)
            # URI#dup does not duplicate internal instance
            # variables, making mutation dangerous.
            URI(stringify_url(url))
          else
            URI(url.to_s)
          end
        end

        # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity

        # Work around a bug in Ruby 3.0.x that erroneously omits
        # the '//' prefix from hierarchical URLs.
        #
        # @api private
        # @since 2.2.0
        def stringify_url(url)
          if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.1.0")
            return url.to_s
          end

          require "stringio"

          buf = StringIO.new
          buf << url.scheme
          buf << ":"
          buf << (url.opaque || "//")

          if url.user || url.password
            buf << "#{url.user}:#{url.password}@"
          end

          if url.host
            buf << url.host
          end

          if url.port
            buf << ":"
            buf << url.port
          end

          if url.path
            buf << url.path
          end

          if url.query
            buf << "?"
            buf << url.query
          end

          if url.fragment
            buf << "#"
            buf << url.fragment
          end

          buf.string
        end

        # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity

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
