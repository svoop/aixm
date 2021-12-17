using AIXM::Refinements

module AIXM

  # Associate features and components with a minimalistic implementation of
  # +has_many+, +has_one+ and +belongs_to+ associations.
  #
  # When adding or assigning an object on the associator (where the +has_many+
  # or +has_one+ declaration is made), the object is verified and must be an
  # instance of the declared class or a superclass thereof.
  #
  # When assigning an object on the associated (where the +belongs_to+
  # declaration is made), the object is not verified. However, since the actual
  # assignment is always delegated to the associator, unacceptable objects will
  # raise errors.
  #
  # @example Simple +has_many+ association
  #   class Blog
  #     has_many :posts   # :post has to be a key in AIXM::CLASSES
  #   end
  #   class Post
  #     belongs_to :blog
  #   end
  #   blog, post = Blog.new, Post.new
  #   # --either--
  #   blog.add_post(post)
  #   blog.posts.count           # => 1
  #   blog.posts.first == post   # => true
  #   post.blog == blog          # => true
  #   blog.remove_post(post)
  #   blog.posts.count           # => 0
  #   # --or--
  #   post.blog = blog
  #   blog.posts.count           # => 1
  #   blog.posts.first == post   # => true
  #   post.blog == blog          # => true
  #   post.blog = nil
  #   blog.posts.count           # => 0
  #   # --or--
  #   post_2 = Post.new
  #   blog.add_posts([post, post_2])
  #   blog.posts.count                    # => 2
  #   blog.posts == [post, post_2]        # => true
  #   blog.remove_posts([post_2, post])
  #   blog.posts.count                    # => 0
  #
  # @example Simple +has_one+ association
  #   class Blog
  #     has_one :posts   # :post has to be a key in AIXM::CLASSES
  #   end
  #   class Post
  #     belongs_to :blog
  #   end
  #   blog, post = Blog.new, Post.new
  #   # --either--
  #   blog.post = post
  #   blog.post == post   # => true
  #   post.blog == blog   # => true
  #   blog.post = nil
  #   blog.post           # => nil
  #   post.blog           # => nil
  #   # --or--
  #   post.blog = blog
  #   post.blog == blog   # => true
  #   blog.post == post   # => true
  #   post.blog = nil
  #   post.blog           # => nil
  #   blog.post           # => nil
  #
  # @example Association with readonly +belongs_to+ (idem for +has_one+)
  #   class Blog
  #     has_many :posts   # :post has to be a key in AIXM::CLASSES
  #   end
  #   class Post
  #     belongs_to :blog, readonly: true
  #   end
  #   blog, post = Blog.new, Post.new
  #   post.blog = blog           # => NoMethodError
  #
  # @example Association with explicit class (idem for +has_one+)
  #   class Blog
  #     include AIXM::Association
  #     has_many :posts, accept: 'Picture'
  #   end
  #   class Picture
  #     include AIXM::Association
  #     belongs_to :blog
  #   end
  #   blog, picture = Blog.new, Picture.new
  #   blog.add_post(picture)
  #   blog.posts.first == picture   # => true
  #
  # @example Polymorphic associator (idem for +has_one+)
  #   class Blog
  #     has_many :posts, as: :postable
  #   end
  #   class Feed
  #     has_many :posts, as: :postable
  #   end
  #   class Post
  #     belongs_to :postable
  #   end
  #   blog, feed, post_1, post_2, post_3 = Blog.new, Feed.new, Post.new, Post.new, Post.new
  #   blog.add_post(post_1)
  #   post_1.postable == blog   # => true
  #   feed.add_post(post_2)
  #   post_2.postable == feed   # => true
  #   post_3.postable = blog    # => NoMethodError
  #
  # @example Polymorphic associated (idem for +has_one+)
  #   class Blog
  #     include AIXM::Association
  #     has_many :items, accept: ['Post', :picture]
  #   end
  #   class Post
  #     include AIXM::Association
  #     belongs_to :blog, as: :item
  #   end
  #   class Picture
  #     include AIXM::Association
  #     belongs_to :blog, as: :item
  #   end
  #   blog, post, picture = Blog.new, Post.new, Picture.new
  #   blog.add_item(post)
  #   blog.add_item(picture)
  #   blog.items.count             # => 2
  #   blog.items.first == post     # => true
  #   blog.items.last == picture   # => true
  #   post.blog == blog            # => true
  #   picture.blog == blog         # => true
  #
  # @example Add method which enriches passed associated object (+has_many+ only)
  #   class Blog
  #     has_many :posts do |post, related_to: nil|      # this defines the signature of add_post
  #       post.related_to = related_to || @posts.last   # executes in the context of the current blog
  #     end
  #   end
  #   class Post
  #     belongs_to :blog
  #     attr_accessor :related_to
  #   end
  #   blog, post_1, post_2, post_3 = Blog.new, Post.new, Post.new, Post.new
  #   blog.add_post(post_1)
  #   post_1.related_to             # => nil
  #   blog.add_post(post_2)
  #   post_2.related_to == post_1   # => true
  #   blog.add_post(post_3, related_to: post_1)
  #   post_3.related_to == post_1   # => true
  #
  # @example Add method which builds and yields new associated object (+has_many+ only)
  #   class Blog
  #     include AIXM::Association
  #     has_many :posts do |post, title:| end
  #   end
  #   class Post
  #     include AIXM::Association
  #     belongs_to :blog
  #     attr_accessor :title, :text
  #     def initialize(title:)   # same signature as "has_many" block above
  #       @title = title
  #     end
  #   end
  #   blog = Blog.new
  #   blog.add_post(title: "title") do |post|   # note that no post instance is passed
  #     post.text = "text"
  #   end
  #   blog.posts.first.title   # => "title"
  #   blog.posts.first.text    # => "text"
  module Association
    module ClassMethods
      attr_reader :has_many_attributes, :has_one_attributes, :belongs_to_attributes

      def has_many(attribute, as: nil, accept: nil, &association_block)
        association = attribute.to_s.inflect(:singularize)
        inversion = as || self.to_s.inflect(:demodulize, :tableize, :singularize)
        class_names = [accept || association].flatten.map { AIXM::CLASSES[_1.to_sym] || _1 }
        (@has_many_attributes ||= []) << attribute
        # features
        define_method(attribute) do
          instance_eval("@#{attribute} ||= AIXM::Association::Array.new")
        end
        # add_feature
        define_method(:"add_#{association}") do |object=nil, **options, &add_block|
          unless object
            fail(ArgumentError, "must pass object to add") if class_names.count > 1
            object = class_names.first.to_class.new(**options)
            add_block.call(object) if add_block
          end
          instance_exec(object, **options, &association_block) if association_block
          fail(ArgumentError, "#{object.__class__} not allowed") unless class_names.any? { |c| object.is_a?(c.to_class) }
          send(attribute).send(:push, object)
          object.instance_variable_set(:"@#{inversion}", self)
          self
        end
        # add_features
        define_method(:"add_#{attribute}") do |objects=[], **options, &add_block|
          objects.each { send(:"add_#{association}", _1, **options, &add_block) }
          self
        end
        # remove_feature
        define_method(:"remove_#{association}") do |object|
          send(attribute).send(:delete, object)
          object.instance_variable_set(:"@#{inversion}", nil)
          self
        end
        # remove_features
        define_method(:"remove_#{attribute}") do |objects=[]|
          objects.each { send(:"remove_#{association}", _1) }
          self
        end
      end

      def has_one(attribute, as: nil, accept: nil, allow_nil: false)
        association = attribute.to_s
        inversion = (as || self.to_s.inflect(:demodulize, :tableize, :singularize)).to_s
        class_names = [accept || association].flatten.map { AIXM::CLASSES[_1.to_sym] || _1 }
        class_names << 'NilClass' if allow_nil
        (@has_one_attributes ||= []) << attribute
        # feature
        attr_reader attribute
        # feature= / add_feature
        define_method(:"#{association}=") do |object|
          fail(ArgumentError, "#{object.__class__} not allowed") unless class_names.any? { |c| object.is_a?(c.to_class) }
          instance_variable_get(:"@#{attribute}")&.instance_variable_set(:"@#{inversion}", nil)
          instance_variable_set(:"@#{attribute}", object)
          object&.instance_variable_set(:"@#{inversion}", self)
        end
        alias_method(:"add_#{association}", :"#{association}=")
        # remove_feature
        define_method(:"remove_#{association}") do |_|
          send(:"#{association}=", nil)
          self
        end
      end

      def belongs_to(attribute, as: nil, readonly: false)
        association = self.to_s.inflect(:demodulize, :tableize, :singularize)
        inversion = (as || association).to_s
        (@belongs_to_attributes ||= []) << attribute
        # feature
        attr_reader attribute
        # feature=
        unless readonly
          define_method(:"#{attribute}=") do |object|
            instance_variable_get(:"@#{attribute}")&.send(:"remove_#{inversion}", self)
            object&.send(:"add_#{inversion}", self)
          end
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    class Array < ::Array
      private :<<, :push, :append, :unshift, :prepend
      private :delete, :pop, :shift

      # Find objects of the given class and optionally with the given
      # attribute values on a has_many association.
      #
      # The class can either be declared by passing the class itself or by
      # passing a shortcut symbol as listed in +AIXM::CLASSES+.
      #
      # @example
      #   class Blog
      #     include AIXM::Association
      #     has_many :items, accept: %i(post picture)
      #   end
      #   class Post
      #     include AIXM::Association
      #     belongs_to :blog, as: :item
      #     attr_accessor :title
      #   end
      #   class Picture
      #     include AIXM::Association
      #     belongs_to :blog, as: :item
      #   end
      #   blog, post, picture = Blog.new, Post.new, Picture.new
      #   post.title = "title"
      #   blog.add_item(post)
      #   blog.add_item(picture)
      #   blog.items.find_by(:post) == [post]                    # => true
      #   blog.items.find_by(Post) == [post]                     # => true
      #   blog.items.find_by(:post, title: "title") == [post]    # => true
      #   blog.items.find_by(Object) == [post, picture]          # => true
      #
      # @param klass [Class, Symbol] class (e.g. AIXM::Feature::Airport,
      #   AIXM::Feature::NavigationalAid::VOR) or shortcut symbol (e.g.
      #   :airport or :vor) as listed in AIXM::CLASSES
      # @param attributes [Hash] search attributes by their values
      # @return [AIXM::Association::Array]
      def find_by(klass, attributes={})
        if klass.is_a? Symbol
          klass = AIXM::CLASSES[klass]&.to_class || fail(ArgumentError, "unknown class shortcut `#{klass}'")
        end
        self.class.new(
          select do |element|
            if element.kind_of? klass
              attributes.all? { |a, v| element.send(a) == v }
            end
          end
        )
      end

      # Find equal objects on a has_many association.
      #
      # This may seem redundant at first, but keep in mind that two instances
      # of +AIXM::CLASSES+ which implement `#to_uid` are considered equal if
      # they are instances of the same class and both their UIDs as calculated
      # by `#to_uid` are equal. Attributes which are not part of the `#to_uid`
      # calculation are irrelevant!
      #
      # @example
      #   class Blog
      #     include AIXM::Association
      #     has_many :items, accept: %i(post picture)
      #   end
      #   class Post
      #     include AIXM::Association
      #     belongs_to :blog, as: :item
      #     attr_accessor :title
      #   end
      #   blog, post = Blog.new, Post.new
      #   blog.add_item(post)
      #   blog.items.find(post) == [post]   # => true
      #
      # @param object [Object] instance of class listed in AIXM::CLASSES
      # @return [AIXM::Association::Array]
      def find(object)
        klass = object.__class__
        self.class.new(
          select do |element|
            element.kind_of?(klass) && element == object
          end
        )
      end

      # Find equal or identical duplicates on a has_many association.
      #
      # @example
      #   class Blog
      #     include AIXM::Association
      #     has_many :posts
      #   end
      #   class Post
      #     include AIXM::Association
      #     belongs_to :blog
      #   end
      #   blog, post = Blog.new, Post.new
      #   duplicate_post = post.dup
      #   blog.add_posts([post, duplicate_post])
      #   blog.posts.duplicates   # => [[post, duplicate_post]]
      #
      # @return [Array<Array<AIXM::Feature>>]
      def duplicates
        AIXM::Memoize.method :to_uid do
          group_by(&:to_uid).select { |_, a| a.count > 1 }.map(&:last)
        end
      end
    end
  end
end
