module AIXM
  module Concerns

    # Memoize the return value of a specific method across multiple instances for
    # the duration of a block.
    #
    # The method signature is taken into account, therefore calls of the same
    # method with different positional and/or keyword arguments are cached
    # independently. On the other hand, when calling the method with a block,
    # no memoization is performed at all.
    #
    # Nested memoization of the same method is allowed and won't reset the
    # memoization cache.
    #
    # @example
    #   class Either
    #     include AIXM::Concerns::Memoize
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
    #   AIXM::Concerns::Memoize.method :either do
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
            if block || !AIXM::Concerns::Memoize.cache.has_key?(method)
              send(unmemoized_method, *args, **kargs, &block)
            else
              cache = AIXM::Concerns::Memoize.cache[method]
              id = object_id.hash ^ args.hash ^ kargs.hash
              if cache.has_key?(id)
                cache[id]
              else
                cache[id] = send(unmemoized_method, *args, **kargs)
              end
            end
          end
          method
        end
      end

      class << self
        attr_reader :cache

        def included(base)
          base.extend(ClassMethods)
          @cache = {}
        end

        def method(method, &block)   # TODO: [ruby-3.1] use anonymous block "&" on this and next line
          send(:"call_with#{:out if cached?(method)}_cache", method, &block)
        end

        private

        def cached?(method)
          cache.has_key?(method)
        end

        def call_without_cache(method)
          yield
        end

        def call_with_cache(method)
          cache[method] = {}
          yield
        ensure
          cache.delete(method)
        end
      end
    end

  end
end
