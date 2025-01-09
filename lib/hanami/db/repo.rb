# frozen_string_literal: true

module Hanami
  module DB
    # @api public
    # @since 2.2.0
    class Repo < ROM::Repository
      # @api public
      # @since 2.2.0
      def self.[](root)
        fetch_or_store(root) do
          # Override ROM::Repository.[] logic to ensure repos with explicit roots inherit from
          # Hanami::DB::Repo itself, instead of the plain old ROM::Repository::Root.
          Class.new(self).tap { |klass|
            klass.root(root)
          }
        end
      end

      # @api public
      # @since 2.2.0
      defines :root

      # @api public
      # @since 2.2.0
      attr_reader :root

      # @api private
      def self.inherited(klass)
        super
        klass.root(root)
      end

      # @api public
      # @since 2.2.0
      def initialize(*, **)
        super

        # Repos in Hanami apps infer a root from their class name (e.g. :posts for PostRepo). This
        # means _every_ repo ends up with an inferred root, many of which will not exist as
        # relations. To avoid errors from fetching these non-existent relations, check first before
        # setting the root.
        @root = prepare_relation(self.class.root) if set_relation?(self.class.root)
      end

      private

      def set_relation?(name)
        name && container.relations.key?(name)
      end
    end
  end
end
