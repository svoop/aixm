require_relative '../../../spec_helper'

describe AIXM::Concerns::Association do
  describe AIXM::Concerns::Association::ClassMethods do
    before do
      $aixm_classes ||= AIXM::CLASSES
    end

    after do
      AIXM::CLASSES.each_key { Object.send(:remove_const, _1.capitalize) }
      module AIXM
        remove_const :CLASSES
        CLASSES = $aixm_classes
      end
    end

    describe "has_many and belongs_to" do
      context "simple association" do
        before do
          module AIXM
            remove_const :CLASSES
            CLASSES = { blog: 'Blog', post: 'Post', picture: 'Picture' }
          end
          class Blog
            include AIXM::Concerns::Association
            has_many :posts
          end
          class Post
            include AIXM::Concerns::Association
            belongs_to :blog
          end
          class Picture
            include AIXM::Concerns::Association
            belongs_to :blog   # no inverse has_many is defined
          end
        end

        let(:blog) { Blog.new }
        let(:post) { Post.new }
        let(:post_2) { Post.new }
        let(:picture) { Picture.new }

        it "keeps track of has_many associations" do
          _(Blog.has_many_attributes).must_equal %i(posts)
        end

        it "keeps track of belongs_to associations" do
          _(Post.belongs_to_attributes).must_equal %i(blog)
        end

        it "fails to add post to posts array of blog" do
          _{ blog.posts << post }.must_raise NoMethodError
        end

        it "adds post to blog and returns blog" do
          _(blog.add_post(post)).must_equal blog
          _(blog.posts).must_equal [post]
          _(post.blog).must_equal blog
        end

        it "adds posts to blog and returns blog" do
          _(blog.add_posts([post, post_2])).must_equal blog
          _(blog.posts).must_equal [post, post_2]
          _(post.blog).must_equal blog
          _(post_2.blog).must_equal blog
        end

        it "removes post from blog and returns blog" do
          _(blog.add_post(post)).must_equal blog
          _(blog.remove_post(post)).must_equal blog
          _(blog.posts).must_equal []
          _(post.blog).must_be :nil?
        end

        it "removes posts from blog and returns blog" do
          _(blog.add_posts([post, post_2])).must_equal blog
          _(blog.remove_posts([post_2, post])).must_equal blog
          _(blog.posts).must_equal []
          _(post.blog).must_be :nil?
          _(post_2.blog).must_be :nil?
        end

        it "fails to add non-post to blog" do
          _{ blog.add_post(Object.new) }.must_raise ArgumentError
        end

        it "assigns blog to post and returns blog" do
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
          module AIXM
            remove_const :CLASSES
            CLASSES = { blog: 'Blog', post: 'Post' }
          end
          class Blog
            include AIXM::Concerns::Association
            has_many :posts
          end
          class Post
            include AIXM::Concerns::Association
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
          module AIXM
            remove_const :CLASSES
            CLASSES = { blog: 'Blog', post: 'Post', picture: 'Picture' }
          end
          class Blog
            include AIXM::Concerns::Association
            has_many :posts, accept: 'Picture'
          end
          class Post
            include AIXM::Concerns::Association
            belongs_to :blog   # no inverse has_many is defined
          end
          class Picture
            include AIXM::Concerns::Association
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
          module AIXM
            remove_const :CLASSES
            CLASSES = { blog: 'Blog', feed: 'Feed', post: 'Post' }
          end
          class Blog
            include AIXM::Concerns::Association
            has_many :posts, as: :postable
          end
          class Feed
            include AIXM::Concerns::Association
            has_many :posts, as: :postable
          end
          class Post
            include AIXM::Concerns::Association
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
          module AIXM
            remove_const :CLASSES
            CLASSES = { blog: 'Blog', post: 'Post', picture: 'Picture' }
          end
          class Blog
            include AIXM::Concerns::Association
            has_many :items, accept: ['Post', :picture]
          end
          class Post
            include AIXM::Concerns::Association
            belongs_to :blog, as: :item
          end
          class Picture
            include AIXM::Concerns::Association
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
          module AIXM
            remove_const :CLASSES
            CLASSES = { blog: 'Blog', post: 'Post' }
          end
          class Blog
            include AIXM::Concerns::Association
            has_many :posts do |post, related_to: nil|
              post.related_to = related_to || posts.last
            end
          end
          class Post
            include AIXM::Concerns::Association
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
          module AIXM
            remove_const :CLASSES
            CLASSES = { blog: 'Blog', post: 'Post' }
          end
          class Blog
            include AIXM::Concerns::Association
            has_many :posts do |post, title:| end
          end
          class Post
            include AIXM::Concerns::Association
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
          _(blog.add_post(title: 'title') { _1.text = 'text' }).must_equal blog
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
          module AIXM
            remove_const :CLASSES
            CLASSES = { blog: 'Blog', post: 'Post', picture: 'Picture' }
          end
          class Blog
            include AIXM::Concerns::Association
            has_one :post
          end
          class Post
            include AIXM::Concerns::Association
            belongs_to :blog
          end
          class Picture
            include AIXM::Concerns::Association
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

        describe '=' do
          it "assigns post to blog and returns post" do
            _(blog.post = post).must_equal post
            _(blog.post).must_equal post
            _(post.blog).must_equal blog
          end

          it "assigns blog to post and returns blog" do
            _(post.blog = blog).must_equal blog
            _(blog.post).must_equal post
            _(post.blog).must_equal blog
          end
        end

        describe 'add' do
          it "assigns post to blog and returns blog" do
            _(blog.add_post(post)).must_equal blog
            _(blog.post).must_equal post
            _(post.blog).must_equal blog
          end

          it "assigns post to blog and returns post" do
            _(post.add_blog(blog)).must_equal post
            _(blog.post).must_equal post
            _(post.blog).must_equal blog
          end
        end

        it "fails to assign nil to blog" do
          _{ blog.post = nil }.must_raise ArgumentError
        end

        it "fails to assign non-post to blog" do
          _{ blog.post = Object.new }.must_raise ArgumentError
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
          module AIXM
            remove_const :CLASSES
            CLASSES = { blog: 'Blog', post: 'Post' }
          end
          class Blog
            include AIXM::Concerns::Association
            has_one :post, allow_nil: true
          end
          class Post
            include AIXM::Concerns::Association
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
          module AIXM
            remove_const :CLASSES
            CLASSES = { blog: 'Blog', post: 'Post' }
          end
          class Blog
            include AIXM::Concerns::Association
            has_one :posts
          end
          class Post
            include AIXM::Concerns::Association
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
          module AIXM
            remove_const :CLASSES
            CLASSES = { blog: 'Blog', post: 'Post', picture: 'Picture' }
          end
          class Blog
            include AIXM::Concerns::Association
            has_one :post, accept: 'Picture'
          end
          class Post
            include AIXM::Concerns::Association
            belongs_to :blog   # no inverse has_many is defined
          end
          class Picture
            include AIXM::Concerns::Association
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
          module AIXM
            remove_const :CLASSES
            CLASSES = { blog: 'Blog', feed: 'Feed', post: 'Post' }
          end
          class Blog
            include AIXM::Concerns::Association
            has_one :post, as: :postable
          end
          class Feed
            include AIXM::Concerns::Association
            has_one :post, as: :postable
          end
          class Post
            include AIXM::Concerns::Association
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
          module AIXM
            remove_const :CLASSES
            CLASSES = { blog: 'Blog', post: 'Post', picture: 'Picture' }
          end
          class Blog
            include AIXM::Concerns::Association
            has_one :item, accept: ['Post', :picture]
          end
          class Post
            include AIXM::Concerns::Association
            belongs_to :blog, as: :item
          end
          class Picture
            include AIXM::Concerns::Association
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

  describe AIXM::Concerns::Association::Array do
    subject do
      AIXM::Factory.document
    end

    describe :find_by do
      it "returns array of elements by class shortcut" do
        subject.features.find_by(:airport).then do |result|
          _(result).must_be_instance_of AIXM::Concerns::Association::Array
          _(result.map(&:id)).must_equal %w(LFNT)
        end
      end

      it "returns array of elements by class" do
        subject.features.find_by(AIXM::Feature::Airport).then do |result|
          _(result).must_be_instance_of AIXM::Concerns::Association::Array
          _(result.map(&:id)).must_equal %w(LFNT)
        end
      end

      it "returns array of elements by class and attributes" do
        subject.features.find_by(:airport, id: "LFNT").then do |result|
          _(result).must_be_instance_of AIXM::Concerns::Association::Array
          _(result.map(&:id)).must_equal %w(LFNT)
        end
      end

      it "returns empty array if nothing matches" do
        subject.features.find_by(:airport, id: "FAKE").then do |result|
          _(result).must_be_instance_of AIXM::Concerns::Association::Array
          _(result).must_be :empty?
        end
      end

      it "fails on invalid shortcut" do
        _{ subject.features.find_by(:fake) }.must_raise ArgumentError
      end
    end

    describe :find do
      it "returns equal objects" do
        object = AIXM::Factory.unit
        _(subject.features.find(object)).must_equal [object]
      end

      it "returns empty array if nothing is equal" do
        _(subject.features.find(Object.new)).must_equal []
      end
    end

    describe :duplicates do
      it "returns empty array if no duplicates exist" do
        subject.features.duplicates.then do |result|
          _(result).must_be_instance_of Array
          _(result).must_be :empty?
        end
      end

      it "returns identical duplicates" do
        feature = subject.features.last
        subject.add_feature feature
        subject.features.duplicates.then do |result|
          _(result).must_be_instance_of Array
          _(result).must_equal [[feature, feature]]
        end
      end

      it "returns equal duplicates" do
        feature = subject.features.last
        dup_feature = feature.dup
        subject.add_feature dup_feature
        subject.features.duplicates.then do |result|
          _(result).must_be_instance_of Array
          _(result).must_equal [[feature, dup_feature]]
        end
      end
    end
  end
end
