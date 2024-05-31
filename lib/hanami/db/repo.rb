# frozen_string_literal: true

module Hanami
  module DB
    # @api public
    # @since 2.2.0
    class Repo < ROM::Repository
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

        @root = set_relation(self.class.root) if self.class.root
      end
    end
  end
end
