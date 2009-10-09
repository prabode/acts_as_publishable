module Publishable 
  def self.included(base)
    base.send :extend, ClassMethods
  end
  
  module ClassMethods
    def acts_as_publishable(options = {})
      cattr_accessor :status_column, :required_fields_for_publishing
      self.status_column = (options[:status_column] || :status).to_s
      self.required_fields_for_publishing = (options[:required_fields_for_publishing] || [])
      
      #      before_create :set_initial_status
      before_save :validate_required_fields_for_publishing_on_save   
      
      # Wraps ActiveRecord::Base.find to conveniently find all records in
      # not ready status.  Options:
      #
      # * +number+ - This is just :first or :all from ActiveRecord +find+
      # * +args+ - The rest of the args are passed down to ActiveRecord +find+
      def find_in_not_ready(number, *args)
        with_status_scope :not_ready do
          find(number, *args)
        end
      end
      
      # Wraps ActiveRecord::Base.find to conveniently find all records in
      # not ready status.  Options:
      #
      # * +number+ - This is just :first or :all from ActiveRecord +find+
      # * +args+ - The rest of the args are passed down to ActiveRecord +find+
      def count_in_not_ready(*args)
        count_in_status(:not_ready, *args)
      end
      
      # Wraps ActiveRecord::Base.find to conveniently find all records in
      # ready status.  Options:
      #
      # * +number+ - This is just :first or :all from ActiveRecord +find+
      # * +args+ - The rest of the args are passed down to ActiveRecord +find+
      def find_in_ready(number, *args)
        with_status_scope :ready do
          find(number, *args)
        end
      end
      
      # Wraps ActiveRecord::Base.find to conveniently find all records in
      # ready status.  Options:
      #
      # * +args+ - The rest of the args are passed down to ActiveRecord +find+
      def count_in_ready(*args)
        count_in_status(:ready, *args)
      end
      
      
      # Wraps ActiveRecord::Base.find to conveniently find all records in
      # published status.  Options:
      #
      # * +number+ - This is just :first or :all from ActiveRecord +find+
      # * +args+ - The rest of the args are passed down to ActiveRecord +find+
      def find_in_published(number, *args)
        with_status_scope :published do
          find(number, *args)
        end
      end
      
      # Wraps ActiveRecord::Base.find to conveniently find all records in
      # published status.  Options:
      #
      # * +args+ - The rest of the args are passed down to ActiveRecord +find+
      def count_in_published(*args)
        count_in_status(:published, *args)
      end
      
      # Wraps ActiveRecord::Base.find to conveniently find all records in
      # archived status.  Options:
      #
      # * +number+ - This is just :first or :all from ActiveRecord +find+
      # * +args+ - The rest of the args are passed down to ActiveRecord +find+
      def find_in_archived(number, *args)
        with_status_scope :archived do
          find(number, *args)
        end
      end
      
      # Wraps ActiveRecord::Base.find to conveniently find all records in
      # archived status.  Options:
      #
      # * +args+ - The rest of the args are passed down to ActiveRecord +find+
      def count_in_archived(*args)
        count_in_status(:archived, *args)
      end
      
      
      protected
      
      def count_in_status(status, *args)
        with_status_scope status do
          count(*args)
        end
      end
      
      
      protected
      def with_status_scope(status) 
        with_scope :find => {:conditions => ["#{table_name}.#{status_column} = ?", status.to_s]} do
          yield if block_given?
        end
      end
      
      
      
      
      send :include, InstanceMethods
    end
  end
  
  module InstanceMethods    
    def set_initial_status
      write_attribute self.class.status_column, "not_ready" if new_record?
    end
    
    def not_ready?
      read_attribute(self.class.status_column).eql?("not_ready")
    end
    
    def ready?
      read_attribute(self.class.status_column).eql?("ready")
    end
    
    def published?
      read_attribute(self.class.status_column).eql?("published")
    end
    
    def archived?
      read_attribute(self.class.status_column).eql?("archived")
    end
    
    def publish
      if not published?
        write_attribute self.class.status_column, "published"
        puts "---publish called--class--#{self.class}---#{read_attribute(self.class.status_column)}-------"
        save
        puts "---publish call completed--class--#{self.class}---#{read_attribute(self.class.status_column)}-------"
      end
    end
    
    def archive
      if not archived?
        write_attribute self.class.status_column, "archived"
        save
      end
    end
    
    def reset
      write_attribute self.class.status_column, "ready"
      save
    end
    alias_method :unpublish, :reset
    
    def validate_required_fields_for_publishing_on_save
      puts "---validate_required_fields_for_publishing_on_save called--class--#{self.class}---#{read_attribute(self.class.status_column)}-------"      
      validate_readiness(true)
      puts "---validate_required_fields_for_publishing_on_save call completed--class--#{self.class}---#{read_attribute(self.class.status_column)}-------"
    end
    
    def validate_readiness(is_on_save = false)
      puts "---validate_readiness called--class--#{self.class}---#{read_attribute(self.class.status_column)}-------"
      
      
      #      path = File.expand_path "#{RAILS_ROOT}/config/locales/en.yml"
      #      error_file = YAML.load_file(path)[self.class.name] || {}
      error_file = {}
      
      old_status = read_attribute(self.class.status_column) || "not_ready"
      write_attribute self.class.status_column, "not_ready"
      
      readiness_errors = []
      
      # Verify our required fields
      self.class.required_fields_for_publishing.each do |field|
        result = self.send(field)
        
        puts "----result.class---#{result.class}--------------"
        if result.kind_of? Array
          valid = result.size > 0
          if result.size > 0
            result.select { |r| r.class.respond_to?(:required_fields_for_publishing)}.each do |r|
              puts "----r.class---#{r.class}--------------"
              puts "----r.class.respond_to?(:acts_as_publishable)---#{r.class.respond_to?(:required_fields_for_publishing)}--------------"              
              if !r.validate_readiness.empty? #r.archived? || 
                valid = false
                break
              end
            end
          end
        elsif result.class.respond_to?(:required_fields_for_publishing)
          valid = result && ["ready", "published", "archived"].include?(result.read_attribute(self.class.status_column))
        elsif result.kind_of? String
          valid = !result.blank?
        else
          valid = result
        end
        
        unless valid
          custom_error = error_file[field.to_s]
          # TODO: i18n
          auto_error = "This #{self.class} needs to have a #{field.to_s.humanize}."
          readiness_errors << (custom_error || auto_error)
        end
      end
      
      puts "----readiness_errors.empty?---#{readiness_errors.empty?}--------------"
      if readiness_errors.empty?
        #        puts old_status
        write_attribute self.class.status_column, (old_status == "not_ready" ? "ready" : old_status)
        if read_attribute(self.class.status_column).eql?("published")
          # Trickle down publication
          
          self.class.required_fields_for_publishing.each do |field|
            result = self.send(field)
            
            puts "----result.class---#{result.class}--------------"
            if result.kind_of? Array
              result.select { |r| r.class.respond_to?(:required_fields_for_publishing) && !r.published? }.each do |r| 
                r.publish 
              end
            elsif result.class.respond_to?(:required_fields_for_publishing) && !result.published?
              result.publish
            end
          end
        else
          self.class.required_fields_for_publishing.each do |field|
            result = self.send(field)
            
            if result.kind_of? Array
              result.select { |r| r.class.respond_to?(:required_fields_for_publishing) && !r.published? }.each do |r| 
                r.reset 
              end
            elsif result.class.respond_to?(:required_fields_for_publishing) && !result.published?
              result.reset
            end
          end
        end
      else
        self.class.required_fields_for_publishing.each do |field|
          result = self.send(field)
          
          if result.kind_of? Array
            result.select { |r| r.class.respond_to?(:required_fields_for_publishing)}.each do |r| 
              r.validate_readiness 
            end
          elsif result.class.respond_to?(:required_fields_for_publishing)
            result.validate_readiness
          end
        end         
      end
      
      save if (!read_attribute(self.class.status_column).eql?(old_status)) && !is_on_save
      puts "---validate_readiness finished--class--#{self.class}---#{read_attribute(self.class.status_column)}-------"
      
      puts "---readiness_errors--class--#{self.class}---#{readiness_errors.length}---#{readiness_errors[0] unless readiness_errors.empty?}----"
      
      readiness_errors
    end
  end
end

ActiveRecord::Base.send :include, Publishable