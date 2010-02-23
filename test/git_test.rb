require File.dirname(__FILE__) + '/test_helper.rb'

class Book < Active

  def test_status_of_magazine_
    book = Book.new
    book.name = "rails"
    book.description = "rails"
    book.authors << author1
    book.authors << author2
    book.save
    
    assert_equal [], bo
    assert_not_nil book.published_at  
  end
  
  def test_book_is_ready
    book = get_book
    
    assert_equal 1, Magazine.count_in_archived()
  end
  
end