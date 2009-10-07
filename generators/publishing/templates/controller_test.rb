require File.dirname(__FILE__) + '/..<%=@name.blank? ? "" : "/.." %>/test_helper.rb'

#source: http://agilewebdevelopment.com/plugins/activerecord_base_without_table
module ActiveRecord
  class BaseWithoutTable < Base
    self.abstract_class = true
    
    def create_or_update
      errors.empty?
    end
    
    class << self
      def columns()
        @columns ||= []
      end
      
      def column(name, sql_type = nil, default = nil, null = true)
        columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
        reset_column_information
      end
      
      # Do not reset @columns
      def reset_column_information
        #        read_methods.each { |name| undef_method(name) }
        @column_names = @columns_hash = @content_columns = @dynamic_methods_hash = @read_methods = nil
      end
      
      # make the stub call 
      def find(id)
        act_as_publishable_object = ActAsPublishableClass.new
        act_as_publishable_object.name = "book1"
        act_as_publishable_object
      end
    end
  end
end

class ActAsPublishableClass < ActiveRecord::BaseWithoutTable
  column :name, :String
  column :status, :String
  column :id, :integer, 4
  
  #  validates_presence_of :name
  
  acts_as_publishable :required_fields_for_publishing => ["name"]
  
  def reload
    self
  end
end

class <%=@name.blank? ? "" : "#{@name}::" %>PublishingControllerTest < ActionController::TestCase
  test "should post publish" do
    post :publish, {"class"=>"ActAsPublishableClass", "id"=>"1"}
    assert_response :success
    assert_not_nil assigns(:model)
    assert_select "img[alt='Published']"
  end
  
  test "should post unpublish" do
    post :unpublish, {"class"=>"ActAsPublishableClass", "id"=>"1"}
    assert_response :success
    assert_not_nil assigns(:model)
    assert_select "img[alt='Ready']"
  end
  
  test "should post archive" do
    post :archive, {"class"=>"ActAsPublishableClass", "id"=>"1"}
    assert_response :success
    assert_not_nil assigns(:model)
    assert_select "img[alt='Archived']"
  end
  
  test "should post reset" do
    post :reset, {"class"=>"ActAsPublishableClass", "id"=>"1"}
    assert_response :success
    assert_not_nil assigns(:model)
    assert_select "img[alt='Ready']"
  end
end
