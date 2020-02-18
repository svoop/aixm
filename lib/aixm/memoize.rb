module AIXM

  # Memoize the return value of a specific method across multiple instances for
  # the duration of a block.
  #
  # The method signature is taken into account, therefore calls of the same
  # method with different positional and/or keyword arguments are cached
  # independently. On the other hand, when calling the method with a block,
  # no memoization is performed at all.
  #
  # @example
  #   class Either
  #     include AIXM::Memoize
  #
  #     def either(argument=nil, keyword: nil, &block)
  #       $entropy || argument || keyword || (block.call if block)
  #     end
  #     memoize :either
  #   end
  #
  #   a, b, c = Either.new, Either.new, Either.new
  #
  #   # No memoization before the block
  #   $entropy = nil
  #   a.either(1)                 # => 1
  #   b.either(keyword: 2)        # => 2
  #   c.either { 3 }              # => 3
  #   $entropy = :not_nil
  #   a.either(1)                 # => :not_nil
  #   b.either(keyword: 2)        # => :not_nil
  #   c.either { 3 }              # => :not_nil
  #
  #   # Memoization inside the block
  #   AIXM::Memoize.method :either do
  #     $entropy = nil
  #     a.either(1)                 # => 1
  #     b.either(keyword: 2)        # => 2
  #     c.either { 3 }              # => 3
  #     $entropy = :not_nil
  #     a.either(1)                 # => 1          (memoized)
  #     b.either(keyword: 2)        # => 2          (memoized)
  #     c.either { 3 }              # => :not_nil   (cannot be memoized)
  #   end
  #
  #   # No memoization after the block
  #   $entropy = nil
  #   a.either(1)                 # => 1
  #   $entropy = :not_nil
  #   a.either(1)                 # => :not_nil
  module Memoize
    module ClassMethods
      def memoize(method)
        unmemoized_method = :"unmemoized_#{method}"
        alias_method unmemoized_method, method
        define_method method do |*args, **kargs, &block|
          if block || !AIXM::Memoize.cache
            send(unmemoized_method, *args, **kargs, &block)
          else
            id = object_id.hash ^ args.hash ^ kargs.hash
            if AIXM::Memoize.cache.has_key?(id)
              AIXM::Memoize.cache[id]
            else
              AIXM::Memoize.cache[id] = send(unmemoized_method, *args, **kargs, &block)
            end
          end
        end
      end
    end

    class << self
      def included(base)
        base.extend(ClassMethods)
        @cache = {}
      end

      def method(method)
        @method = method
        @cache[@method] = {}
        yield
      ensure
        @method = nil
      end

      def cache
        (@cache[@method] ||= {}) if @method
      end
    end
  end
end
