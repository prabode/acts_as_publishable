ActiveRecord::Schema.define(:version => 0) do  
  create_table :books, :force => true do |t| 
    t.string :name
    t.string :description
    t.string :status  
    t.datetime :created_at  
  end
  
  create_table :magazines, :force => true do |t| 
    t.string :name
    t.string :description
    t.string :stage  
    t.datetime :created_at  
  end
  
  create_table :authors, :force => true do |t| 
    t.string :name
    t.string :bio
    t.string :status  
    t.datetime :created_at  
  end
  
  create_table :book_authors, :force => true do |t|
    t.integer :book_id
    t.integer :author_id 
  end
  
  create_table :publishers, :force => true do |t| 
    t.string :name 
    t.string :status 
    t.datetime :created_at  
  end
  
  create_table :publisher_authors, :force => true do |t|
    t.integer :publisher_id
    t.integer :author_id 
  end
end 