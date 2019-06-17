##
# Provides utilities for checking the shape of deeply-nested hashes, such as
# for validating JSON.
module Hashape
  ##
  # The library version.
  VERSION = '1.0.0'

  ##
  # Specifiers which can provide additional typing to shapes.
  module Specifiers
    ##
    # The basic specifier. You should probably never use this.
    class Specifier
      attr_reader :spec

      ##
      # A shorthand for constructing an instance of any specifier.
      # @param [*] spec The type spec for this specifier to match against.
      # @return [Specifier] A new specifier.
      def self.[](spec)
        Specifier.new(spec)
      end

      ##
      # Creates a new specifier.
      # @param [*] spec The type spec for this specifier to match against.
      # @return [Specifier] A new specifier.
      def initialize(spec)
        @spec = spec
      end
    end

    ##
    # Allows a type spec to also be nil.
    class Optional < Specifier
      def ===(v)
        v.nil? || self.spec === v
      end
    end

    ##
    # Given a list of type specs, allows the value to match any one of those
    # type specs.
    class OneOf < Specifier
      def ===(v)
        raise 'spec for OneOf must be an array' unless self.spec.is_a?(Array)
        self.spec.any? { |s| s === v }
      end
    end

    ##
    # Requires that the value be an enumerable, where each item matches the
    # given type spec.
    class Many < Specifier
      def ===(v)
        v.is_a?(Enumerable) && v.all? { |i| self.spec === i }
      end
    end
  end

  ##
  # Raised when Shape#matches! fails.
  class ShapeMatchError < StandardError
  end

  ##
  # A template hash representing how a hash should be structured, allowing
  # other hashes to be validated against it.
  class Shape
    attr_reader :shape

    ##
    # Create a new shape.
    # @param [Hash] shape The template hash.
    # @return [Shape] The new shape.
    def initialize(shape)
      @shape = shape
    end

    ##
    # Returns a boolean indicating whether the given hash matches the template
    # hash which this shape was constructed with.
    # @param [Hash] subject The hash to compare the template hash against.
    # @return [TrueClass|FalseClass] A boolean indicating whether the subject
    #   hash matches the template hash.
    def matches?(subject)
      matches!(subject)
      true
    rescue ShapeMatchError
      false
    end

    ##
    # Calls #matches? and raises a RuntimeError if it does not return true.
    # @param [Hash] subject The hash to compare the template hash against.
    def matches!(subject)
      shape.each do |k, spec|
        v = subject[k]
        if v.is_a?(Hash) && spec.is_a?(Hash)
          Shape.new(spec).matches!(v)
        else
          unless spec === v
            raise ShapeMatchError,
              "key #{k} with value #{v} does not match spec #{spec}" \
          end
        end
      end
    end
  end

  ##
  # Create a new shape.
  # @param [Hash] shape The template hash.
  # @return [Shape] The new shape. 
  def self.shape(shape)
    Shape.new(shape)
  end
end