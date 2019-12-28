require_relative '../../spec_helper'

describe AIXM::Association do
  describe AIXM::Association::ClassMethods do
    before do
      @@aixm_classes = AIXM::CLASSES
    end

    after do
      AIXM::CLASSES.each_key { |c| Object.send(:remove_const, c.capitalize) }
      AIXM::CLASSES = @@aixm_classes
    end

    describe "has_many and belongs_to" do
      context "simple association" do
        before do
          AIXM::CLASSES = { blog: 'Blog', post: 'Post', picture: 'Picture' }
          class Blog
            include AIXM::Association
            has_many :posts
          end
          class Post
            include AIXM::Association
            belongs_to :blog
          end
          class Picture
            include AIXM::Association
            belongs_to :blog   # no inverse has_many is defined
          end
        end

        let(:blog) { Blog.new }
        let(:post) { Post.new }
        let(:picture) { Picture.new }

        it "keeps track of has_many associations" do
          _(Blog.has_many_attributes).must_equal %i(posts)
        end

        it "keeps track of belongs_to associations" do
          _(Post.belongs_to_attributes).must_equal %i(blog)
        end

        it "adds post to blog" do
          _(blog.add_post(post)).must_equal blog
          _(blog.posts).must_equal [post]
          _(post.blog).must_equal blog
        end

        it "removes post from blog" do
          _(blog.add_post(post)).must_equal blog
          _(blog.remove_post(post)).must_equal blog
          _(blog.posts).must_equal []
          _(post.blog).must_be :nil?
        end

        it "fails to add non-post to blog" do
          _{ blog.add_post(Object.new) }.must_raise ArgumentError
        end

        it "assigns blog to post" do
          _(post.blog = blog).must_equal blog
          _(blog.posts).must_equal [post]
          _(post.blog).must_equal blog
        end

        it "assigns nil to post" do
          _(post.blog = blog).must_equal blog
          _(post.blog = nil).must_be :nil?
          _(post.blog).must_be :nil?
          _(blog.posts).must_equal []
        end

        it "fails to assign non-blog to post" do
          _{ post.blog = Object.new }.must_raise NoMethodError
        end

        it "fails to assign blog to picture" do
          _{ picture.blog = blog }.must_raise NoMethodError
        end
      end

      context "association with readonly belongs_to" do
        before do
          AIXM::CLASSES = { blog: 'Blog', post: 'Post' }
          class Blog
            include AIXM::Association
            has_many :posts
          end
          class Post
            include AIXM::Association
            belongs_to :blog, readonly: true
          end
        end

        let(:blog) { Blog.new }
        let(:post) { Post.new }

        it "cannot assign blog to post" do
          _{ post.blog = blog }.must_raise NoMethodError
        end
      end

      context "association with explicit class" do
        before do
          AIXM::CLASSES = { blog: 'Blog', post: 'Post', picture: 'Picture' }
          class Blog
            include AIXM::Association
            has_many :posts, accept: 'Picture'
          end
          class Post
            include AIXM::Association
            belongs_to :blog   # no inverse has_many is defined
          end
          class Picture
            include AIXM::Association
            belongs_to :blog
          end
        end

        let(:blog) { Blog.new }
        let(:post) { Post.new }
        let(:picture) { Picture.new }

        it "adds picture to blog" do
          _(blog.add_post(picture)).must_equal blog
          _(blog.posts).must_equal [picture]
          _(picture.blog).must_equal blog
        end

        it "fails to add non-post to blog" do
          _{ blog.add_post(Object.new) }.must_raise ArgumentError
        end

        it "fails to assign blog to post" do
          _{ post.blog = blog }.must_raise ArgumentError
        end
      end

      context "polymorphic associator" do
        before do
          AIXM::CLASSES = { blog: 'Blog', feed: 'Feed', post: 'Post' }
          class Blog
            include AIXM::Association
            has_many :posts, as: :postable
          end
          class Feed
            include AIXM::Association
            has_many :posts, as: :postable
          end
          class Post
            include AIXM::Association
            belongs_to :postable
          end
        end

        let(:blog) { Blog.new }
        let(:feed) { Feed.new }
        let(:post) { Post.new }

        it "adds post to blog" do
          _(blog.add_post(post)).must_equal blog
          _(blog.posts).must_equal [post]
          _(post.postable).must_equal blog
        end

        it "removes post from blog" do
          _(blog.add_post(post)).must_equal blog
          _(blog.remove_post(post)).must_equal blog
          _(blog.posts).must_equal []
          _(post.postable).must_be :nil?
        end

        it "fails to add non-post to blog" do
          _{ blog.add_post(Object.new) }.must_raise ArgumentError
        end

        it "adds post to feed" do
          _(feed.add_post(post)).must_equal feed
          _(feed.posts).must_equal [post]
          _(post.postable).must_equal feed
        end

        it "fails to add non-post to feed" do
          _{ blog.add_post(Object.new) }.must_raise ArgumentError
        end

        it "assigns blog to post" do
          _(post.postable = feed).must_equal feed
          _(feed.posts).must_equal [post]
        end

        it "assigns nil to post" do
          _(post.postable = blog).must_equal blog
          _(post.postable = nil).must_be :nil?
          _(post.postable).must_be :nil?
          _(blog.posts).must_equal []
        end
      end

      context "polymorphic associated" do
        before do
          AIXM::CLASSES = { blog: 'Blog', post: 'Post', picture: 'Picture' }
          class Blog
            include AIXM::Association
            has_many :items, accept: ['Post', :picture]
          end
          class Post
            include AIXM::Association
            belongs_to :blog, as: :item
          end
          class Picture
            include AIXM::Association
            belongs_to :blog, as: :item
          end
        end

        let(:blog) { Blog.new }
        let(:post) { Post.new }
        let(:picture) { Picture.new }

        it "adds post or picture to blog" do
          _(blog.add_item(post)).must_equal blog
          _(blog.items).must_equal [post]
          _(post.blog).must_equal blog
          _(blog.add_item(picture)).must_equal blog
          _(blog.items).must_equal [post, picture]
          _(picture.blog).must_equal blog
        end

        it "removes post or picture from blog" do
          _(blog.add_item(post)).must_equal blog
          _(blog.add_item(picture)).must_equal blog
          _(blog.remove_item(post)).must_equal blog
          _(blog.items).must_equal [picture]
          _(post.blog).must_be :nil?
          _(blog.remove_item(picture)).must_equal blog
          _(blog.items).must_equal []
          _(picture.blog).must_be :nil?
        end

        it "assigns blog to post or picture" do
          _(post.blog = blog).must_equal blog
          _(post.blog).must_equal blog
          _(blog.items).must_equal [post]
          _(picture.blog = blog).must_equal blog
          _(picture.blog).must_equal blog
          _(blog.items).must_equal [post, picture]
        end

        it "assigns nil to post or picture" do
          _(post.blog = blog).must_equal blog
          _(picture.blog = blog).must_equal blog
          _(post.blog = nil).must_be :nil?
          _(post.blog).must_be :nil?
          _(blog.items).must_equal [picture]
          _(picture.blog = nil).must_be :nil?
          _(picture.blog).must_be :nil?
          _(blog.items).must_equal []
        end

        it "fails to add non-post/picture to blog" do
          _{ blog.add_item(Object.new) }.must_raise ArgumentError
        end
      end

      context "add method which enriches associated object" do
        before do
          AIXM::CLASSES = { blog: 'Blog', post: 'Post' }
          class Blog
            include AIXM::Association
            has_many :posts do |post, related_to: nil|
              post.related_to = related_to || posts.last
            end
          end
          class Post
            include AIXM::Association
            belongs_to :blog
            attr_accessor :related_to
          end
        end

        let(:blog) { Blog.new }
        let(:post_1) { Post.new }
        let(:post_2) { Post.new }
        let(:post_3) { Post.new }

        it "adds post to blog and relates between posts" do
          _(blog.add_post(post_1)).must_equal blog
          _(post_1.related_to).must_be :nil?
          _(blog.add_post(post_2)).must_equal blog
          _(post_2.related_to).must_equal post_1
          _(blog.add_post(post_3, related_to: post_1)).must_equal blog
          _(post_3.related_to).must_equal post_1
        end
      end

      context "add method which builds associated object on the fly" do
        before do
          AIXM::CLASSES = { blog: 'Blog', post: 'Post' }
          class Blog
            include AIXM::Association
            has_many :posts do |post, title:| end
          end
          class Post
            include AIXM::Association
            belongs_to :blog
            attr_accessor :title, :text
            def initialize(title:);
              @title = title
            end
          end
        end

        let(:blog) { Blog.new }
        let(:post) { Post.new }

        it "creates and adds post to blog" do
          _(blog.add_post(title: 'title') { |p| p.text = 'text' }).must_equal blog
          _(blog.posts.count).must_equal 1
          _(blog.posts.first.title).must_equal 'title'
          _(blog.posts.first.text).must_equal 'text'
        end

        it "fails to add posts with missing arguments" do
          _{ blog.add_post(post) }.must_raise ArgumentError
        end

        it "fails if mandatory arguments are missing" do
          _{ blog.add_post }.must_raise ArgumentError
        end
      end
    end

    describe "has_one and belongs_to" do
      context "simple association" do
        before do
          AIXM::CLASSES = { blog: 'Blog', post: 'Post', picture: 'Picture' }
          class Blog
            include AIXM::Association
            has_one :post
          end
          class Post
            include AIXM::Association
            belongs_to :blog
          end
          class Picture
            include AIXM::Association
            belongs_to :blog   # no inverse has_many is defined
          end
        end

        let(:blog) { Blog.new }
        let(:post) { Post.new }
        let(:picture) { Picture.new }

        it "keeps track of has_one associations" do
          _(Blog.has_one_attributes).must_equal %i(post)
        end

        it "keeps track of belongs_to associations" do
          _(Post.belongs_to_attributes).must_equal %i(blog)
        end

        it "assigns post to blog" do
          _(blog.post = post).must_equal post
          _(blog.post).must_equal post
          _(post.blog).must_equal blog
        end

        it "fails to assign nil to blog" do
          _{ blog.post = nil }.must_raise ArgumentError
        end

        it "fails to assign non-post to blog" do
          _{ blog.post = Object.new }.must_raise ArgumentError
        end

        it "assigns blog to post" do
          _(post.blog = blog).must_equal blog
          _(blog.post).must_equal post
          _(post.blog).must_equal blog
        end

        it "fails to assign nil to post" do
          _(post.blog = blog).must_equal blog
          _{ post.blog = nil }.must_raise ArgumentError
        end

        it "fails to assign non-blog to post" do
          _{ post.blog = Object.new }.must_raise NoMethodError
        end

        it "fails to assign blog to picture" do
          _{ picture.blog = blog }.must_raise NoMethodError
        end
      end

      context "association allowing nil" do
        before do
          AIXM::CLASSES = { blog: 'Blog', post: 'Post' }
          class Blog
            include AIXM::Association
            has_one :post, allow_nil: true
          end
          class Post
            include AIXM::Association
            belongs_to :blog
          end
        end

        let(:blog) { Blog.new }
        let(:post) { Post.new }

        it "assigns nil to blog" do
          _(blog.post = post).must_equal post
          _(blog.post = nil).must_be :nil?
          _(blog.post).must_be :nil?
          _(post.blog).must_be :nil?
        end

        it "assigns nil to post" do
          _(post.blog = blog).must_equal blog
          _(post.blog = nil).must_be :nil?
          _(post.blog).must_be :nil?
          _(blog.post).must_be :nil?
        end
      end

      context "association with readonly belongs_to" do
        before do
          AIXM::CLASSES = { blog: 'Blog', post: 'Post' }
          class Blog
            include AIXM::Association
            has_one :posts
          end
          class Post
            include AIXM::Association
            belongs_to :blog, readonly: true
          end
        end

        let(:blog) { Blog.new }
        let(:post) { Post.new }

        it "cannot assign blog to post" do
          _{ post.blog = blog }.must_raise NoMethodError
        end
      end

      context "association with explicit class" do
        before do
          AIXM::CLASSES = { blog: 'Blog', post: 'Post', picture: 'Picture' }
          class Blog
            include AIXM::Association
            has_one :post, accept: 'Picture'
          end
          class Post
            include AIXM::Association
            belongs_to :blog   # no inverse has_many is defined
          end
          class Picture
            include AIXM::Association
            belongs_to :blog
          end
        end

        let(:blog) { Blog.new }
        let(:post) { Post.new }
        let(:picture) { Picture.new }

        it "assigns picture to blog" do
          _(blog.post = picture).must_equal picture
          _(blog.post).must_equal picture
          _(picture.blog).must_equal blog
        end

        it "fails to assign non-post to blog" do
          _{ blog.post = Object.new }.must_raise ArgumentError
        end

        it "fails to assign blog to post" do
          _{ post.blog = blog }.must_raise ArgumentError
        end
      end

      context "polymorphic associator" do
        before do
          AIXM::CLASSES = { blog: 'Blog', feed: 'Feed', post: 'Post' }
          class Blog
            include AIXM::Association
            has_one :post, as: :postable
          end
          class Feed
            include AIXM::Association
            has_one :post, as: :postable
          end
          class Post
            include AIXM::Association
            belongs_to :postable
          end
        end

        let(:blog) { Blog.new }
        let(:feed) { Feed.new }
        let(:post) { Post.new }

        it "assigns post to blog" do
          _(blog.post = post).must_equal post
          _(blog.post).must_equal post
          _(post.postable).must_equal blog
        end

        it "fails to assign non-post to blog" do
          _{ blog.post = Object.new }.must_raise ArgumentError
        end

        it "assigns post to feed" do
          _(feed.post = post).must_equal post
          _(feed.post).must_equal post
          _(post.postable).must_equal feed
        end

        it "fails to assign non-post to feed" do
          _{ feed.post = Object.new }.must_raise ArgumentError
        end
      end

      context "polymorphic associated" do
        before do
          AIXM::CLASSES = { blog: 'Blog', post: 'Post', picture: 'Picture' }
          class Blog
            include AIXM::Association
            has_one :item, accept: ['Post', :picture]
          end
          class Post
            include AIXM::Association
            belongs_to :blog, as: :item
          end
          class Picture
            include AIXM::Association
            belongs_to :blog, as: :item
          end
        end

        let(:blog) { Blog.new }
        let(:post) { Post.new }
        let(:picture) { Picture.new }

        it "assigns post or picture to blog" do
          _(blog.item = post).must_equal post
          _(blog.item).must_equal post
          _(post.blog).must_equal blog
          _(blog.item = picture).must_equal picture
          _(blog.item).must_equal picture
          _(picture.blog).must_equal blog
        end

        it "assigns blog to post or picture" do
          _(post.blog = blog).must_equal blog
          _(post.blog).must_equal blog
          _(blog.item).must_equal post
          _(picture.blog = blog).must_equal blog
          _(picture.blog).must_equal blog
          _(blog.item).must_equal picture
        end

        it "fails to assign non-post/picture to blog" do
          _{ blog.item = Object.new }.must_raise ArgumentError
        end
      end
    end
  end

  describe AIXM::Association::Array do
    describe :find do
      subject do
        AIXM::Factory.document
      end

      it "returns array of elements by class shortcut" do
        result = subject.features.find(:airport)
        _(result).must_be_instance_of AIXM::Association::Array
        _(result.map(&:id)).must_equal %w(LFNT)
      end

      it "returns array of elements by class" do
        result = subject.features.find(AIXM::Feature::Airport)
        _(result).must_be_instance_of AIXM::Association::Array
        _(result.map(&:id)).must_equal %w(LFNT)
      end

      it "returns array of elements by class and attributes" do
        result = subject.features.find(:airport, id: "LFNT")
        _(result).must_be_instance_of AIXM::Association::Array
        _(result.map(&:id)).must_equal %w(LFNT)
      end

      it "returns empty array if nothing matches" do
        result = subject.features.find(:airport, id: "FAKE")
        _(result).must_be_instance_of AIXM::Association::Array
        _(result).must_be :empty?
      end

      it "fails on invalid shortcut" do
        _{ subject.features.find(:fake) }.must_raise ArgumentError
      end
    end
  end
end
