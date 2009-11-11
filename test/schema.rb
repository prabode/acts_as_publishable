ActiveRecord::Schema.define(:version => 0) do  
  create_table :books, :force => true do |t| 
    t.string :name
    t.string :description
    t.string :status  
    t.datetime :created_at
    t.datetime :published_at
    t.datetime :archived_at
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
  
  create_table :chapters, :force => true do |t|
    t.integer :magazine_id
    t.string :name 
  end
  
  #many to many
  create_table :physicians, :force => true do |t|
    t.string :name
    t.string :status
  end
  
  create_table :patients, :force => true do |t|
    t.string :name
    t.string :status
  end
  
  create_table :appointments, :force => true do |t|
    t.integer :physician_id
    t.integer :patient_id
  end
  
  #one to many
  create_table :teams, :force => true do |t|
    t.string :name
    t.string :status
  end
  
  create_table :players, :force => true do |t|
    t.string :name
    t.string :status
    t.integer :team_id
  end
  
  #one to one   
  create_table :boys, :force => true do |t|
    t.string :name
    t.string :status
  end
  
  create_table :girls, :force => true do |t|
    t.string :name
    t.string :status
    t.integer :boy_id
  end
end 