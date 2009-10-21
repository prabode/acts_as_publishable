require File.dirname(__FILE__) + '/test_helper.rb'

class Book < ActiveRecord::Base
  #  :status_column => :status
  acts_as_publishable :required_fields_for_publishing => ["name", "description", "authors"]
  
  has_many :book_authors
  has_many :authors, :through => :book_authors
end

class Author < ActiveRecord::Base
  acts_as_publishable :required_fields_for_publishing => ["name", "bio", "publishers"]
  has_many :book_authors
  has_many :books, :through => :book_authors
  has_many :publisher_authors
  has_many :publishers, :through => :publisher_authors
end

class BookAuthor < ActiveRecord::Base
  belongs_to :book
  belongs_to :author
end

class Publisher < ActiveRecord::Base
  acts_as_publishable :required_fields_for_publishing => ["name"]
  has_many :publisher_authors
  has_many :authors, :through => :publisher_authors
end

class PublisherAuthor < ActiveRecord::Base
  belongs_to :publisher
  belongs_to :author
end

class Magazine < ActiveRecord::Base
  has_many :chapters
  acts_as_publishable :status_column => :stage, :required_fields_for_publishing => ["name", "description", "chapters"]
end

class Chapter < ActiveRecord::Base
  belongs_to :magazine
end

class ActAsPublishableTest < Test::Unit::TestCase
  load_schema
  
  def test_book_publishing_field_should_be_status
    assert_equal "status", Book.status_column
  end
  
  def test_magazine_publishing_field_should_be_status
    assert_equal "stage", Magazine.status_column
  end
  
  def test_book_required_fields_for_publishing_should_be_equal_to_three
    assert_equal 3, Book.required_fields_for_publishing.size
  end
  
  def test_magazine_required_fields_for_publishing_should_be_equal_to_two
    assert_equal 3, Magazine.required_fields_for_publishing.size
  end
  
  def test_initial_status_of_book
    book = Book.new
    book.save
    assert_equal "not_ready", book.status
  end
  
  def test_initial_status_of_magazine
    chapter = Chapter.create
    
    magazine = Magazine.new
    magazine.name = "mag"
    magazine.description = "mag"
    magazine.chapters << chapter
    magazine.save
    assert_equal "ready", magazine.stage
  end
  
  def test_status_of_magazine_should_be_not_ready
    chapter = Chapter.create
    magazine = Magazine.new
    magazine.name = "mag"
    magazine.description = "mag"
    magazine.chapters << chapter
    magazine.save
    assert_equal "ready", magazine.stage
    magazine.name = ""  
    magazine.save
    assert_equal "not_ready", magazine.stage
  end
  
  def test_book_publishing_status_not_ready_with_publishers_being_not_ready
    publisher = Publisher.create(:name => "")
    
    author1 = Author.create(:name => "sam", :bio => "some bio sam")
    author2 = Author.create(:name => "ann", :bio => "some bio ann")
    
    author1.publishers << publisher
    author2.publishers << publisher
    
    book = Book.new
    book.name = "rails"
    book.description = "rails"
    book.authors << author1
    book.authors << author2
    book.save
    
    assert_not_equal [], book.validate_readiness
    assert_equal "not_ready", book.status
    assert_equal "not_ready", author1.status
    assert_equal "not_ready", author2.status
    assert_equal "not_ready", publisher.status    
  end
  
  def test_book_publishing_status_not_ready_with_author1_being_not_ready
    publisher = Publisher.create(:name => "wrox")
    
    author1 = Author.create(:name => "", :bio => "some bio sam")
    author2 = Author.create(:name => "ann", :bio => "some bio ann")
    
    author1.publishers << publisher
    author2.publishers << publisher
    
    book = Book.new
    book.name = "rails"
    book.description = "rails"
    book.authors << author1
    book.authors << author2
    book.save
    
    assert_not_equal [], book.validate_readiness
    assert_equal "not_ready", book.status
    assert_equal "not_ready", author1.status
    assert_equal "ready", author2.status
    assert_equal "ready", publisher.status    
  end
  
  def test_book_publishing_status_not_ready_with_book_being_not_ready
    publisher = Publisher.create(:name => "wrox")
    
    author1 = Author.create(:name => "sam", :bio => "some bio sam")
    author2 = Author.create(:name => "ann", :bio => "some bio ann")
    
    author1.publishers << publisher
    author2.publishers << publisher
    
    book = Book.new
    book.name = ""
    book.description = "rails"
    book.authors << author1
    book.authors << author2
    book.save
    
    assert_not_equal [], book.validate_readiness
    assert_equal "not_ready", book.status
    assert_equal "ready", author1.status
    assert_equal "ready", author2.status
    assert_equal "ready", publisher.status    
  end
  
  def test_book_publishing_status_ready_with_authers_publishers
    publisher = Publisher.create(:name => "wrox")
    
    author1 = Author.create(:name => "sam", :bio => "some bio sam")
    author2 = Author.create(:name => "ann", :bio => "some bio ann")
    
    author1.publishers << publisher
    author2.publishers << publisher
    
    book = Book.new
    book.name = "rails"
    book.description = "rails"
    book.authors << author1
    book.authors << author2
    book.save
    
    assert_equal [], book.validate_readiness
    assert_equal "ready", book.status
    assert_equal "ready", author1.status
    assert_equal "ready", author2.status
    assert_equal "ready", publisher.status    
  end
  
  def test_book_publishing_status_published_with_authers_publishers
    publisher = Publisher.create(:name => "wrox")
    
    author1 = Author.create(:name => "sam", :bio => "some bio sam")
    author2 = Author.create(:name => "ann", :bio => "some bio ann")
    
    author1.publishers << publisher
    author2.publishers << publisher
    
    book = Book.new
    book.name = "rails"
    book.description = "rails"
    book.authors << author1
    book.authors << author2
    book.save
    assert_nil book.published_at
    
    book.publish
    
    assert_equal "published", book.status
    assert_equal "published", author1.status
    assert_equal "published", author2.status
    assert_equal "published", publisher.status  
    
    assert_not_nil book.published_at  
  end
  
  def test_book_is_ready
    book = get_book
    assert_equal "ready", book.status
    assert_equal true, book.ready?
    assert_equal true, book.authors[0].ready?
    assert_equal true, book.authors[1].ready?
    assert_equal true, book.authors[0].publishers[0].ready?
  end
  
  def test_book_is_published
    book = get_book
    book.publish
    assert_equal "published", book.status
    assert_equal true, book.published?   
    assert_equal true, book.authors[0].published?
    assert_equal true, book.authors[1].published?
    assert_equal true, book.authors[0].publishers[0].published?
  end
  
  def test_book_is_archived
    book = get_book
    book.publish
    assert_equal "published", book.status
    assert_not_nil book.published_at
    assert_nil book.archived_at  
    book.archive
    assert_equal "archived", book.status 
    assert_equal true, book.archived? 
    assert_equal true, book.authors[0].published?
    assert_equal true, book.authors[1].published?
    assert_equal true, book.authors[0].publishers[0].published?
    
    assert_not_nil book.archived_at
  end
  
  def test_book_is_not_ready_from_archived
    book = get_book
    book.publish
    assert_equal "published", book.status
    assert_not_nil book.published_at
    book.archive
    assert_equal "archived", book.status 
    assert_not_nil book.archived_at
    book.reset
    assert_equal "ready", book.status
    assert_nil book.published_at
    assert_nil book.archived_at
    
    assert_equal true, book.authors[0].published?
    assert_equal true, book.authors[1].published?
    assert_equal true, book.authors[0].publishers[0].published?
  end
  
  def test_book_is_back_to_ready_from_published
    book = get_book 
    book.publish
    assert_equal "published", book.status
    book.unpublish
    assert_equal "ready", book.status
    assert_equal true, book.authors[0].published?
    assert_equal true, book.authors[1].published?
    assert_equal true, book.authors[0].publishers[0].published?
  end
  
  def test_status_deep_associations
    book = get_book 
    book.publish
    assert_equal "published", book.status
    book.archive
    book.authors[0].archive
    book.reset
    assert_equal "ready", book.status
    assert_equal true, book.ready?
#    puts book.authors[0].status
    assert_equal true, book.authors[0].ready?
    assert_equal true, book.authors[1].published?
    assert_equal true, book.authors[0].publishers[0].published?
  end
  
  def test_archive_status_in_deep_associations
    book = get_book 
    book.publish
    assert_equal "published", book.status
    book.archive
    book.authors[0].archive

    assert_equal true, book.authors[0].archived?
  end
  
  
  def test_find_in_not_ready_status
    assert_equal 3, Book.find_in_not_ready(:all).size
  end
  
  
  def test_count_in_not_ready_status
    assert_equal 3, Book.count_in_not_ready()
  end
  
  def test_find_in_ready_status
    assert_equal 4, Book.find_in_ready(:all).size
  end
  
  
  def test_count_in_ready_status
    assert_equal 4, Book.count_in_ready()
  end
  
  
  def test_find_in_published_status
    assert_equal 6, Publisher.find_in_published(:all).size
  end
  
  
  def test_count_in_published_status
    assert_equal 6, Publisher.count_in_published()
  end
  
  def test_find_in_archived_status
    assert_equal 1, Author.find_in_archived(:all).size
  end
  
  
  def test_count_in_archived_status
    assert_equal 1, Author.count_in_archived()
  end
  
  
  def get_book
    publisher = Publisher.create(:name => "wrox")
    
    author1 = Author.create(:name => "sam", :bio => "some bio sam")
    author2 = Author.create(:name => "ann", :bio => "some bio ann")
    
    author1.publishers << publisher
    author2.publishers << publisher
    
    book = Book.new
    book.name = "rails"
    book.description = "rails"
    book.authors << author1
    book.authors << author2
    book.save
    book
  end
end