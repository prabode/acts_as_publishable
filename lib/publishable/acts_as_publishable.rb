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
    attr_accessor :main_caller
    
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
        current_time = Time.zone.now
        write_attribute :published_at, (current_time - ((current_time.min % 15)*60) - current_time.sec)  if (self.respond_to?(:published_at) && read_attribute("published_at").nil?)
        save
      end
    end
    
    def archive
      if not archived?
        write_attribute self.class.status_column, "archived"
        current_time = Time.zone.now
        write_attribute :archived_at, (current_time - ((current_time.min % 15)*60) - current_time.sec) if (self.respond_to?(:archived_at) && read_attribute("archived_at").nil?)
        save
      end
    end
    
    def reset
      write_attribute self.class.status_column, "ready"
      write_attribute :published_at, nil if self.respond_to?(:published_at)
      write_attribute :archived_at, nil if self.respond_to?(:archived_at)
      save
    end
    alias_method :unpublish, :reset
    
    def validate_required_fields_for_publishing_on_save
      validate_readiness(true)
    end
    
    def validate_readiness(is_on_save = false)
      self.main_caller = (self.main_caller || self.class.name)       
      old_status = read_attribute(self.class.status_column) || "not_ready"
      write_attribute self.class.status_column, "not_ready"
      
      readiness_errors = []
      
      # Verify our required fields
      self.class.required_fields_for_publishing.each do |field|
        result = self.send(field)
        if result.kind_of? Array
          if result.name.eql?(self.main_caller)
            valid = true
          else 
            valid = result.size > 0
            if valid
              #validate the elements of the array
              valid = false
              result.each do |r|
                if r.class.respond_to?(:required_fields_for_publishing)
                  r.main_caller = self.main_caller
                  if r.validate_readiness(true).empty?
                    valid = true
                    break
                  end
                else
                  valid = true
                  break
                end
              end
            end
          end
        elsif result.class.respond_to?(:required_fields_for_publishing)
          result.main_caller = self.main_caller
          valid = result.class.name.eql?(self.main_caller) || result.validate_readiness(false).empty?
        elsif result.kind_of? String
          valid = !result.blank?
        else
          valid = result
        end
        
        unless valid
          error_key = "#{self.class.name.downcase!}_#{field}"
          readiness_error = I18n.t(error_key,:scope => 'publishable',:default=>"This #{self.class.name.downcase!} needs a/an #{field.singularize}.")
          readiness_errors << readiness_error
        end
      end
      
      if readiness_errors.empty?
        write_attribute self.class.status_column, (old_status == "not_ready" ? "ready" : old_status)
        if read_attribute(self.class.status_column).eql?("published")
          # Trickle down publication
          self.class.required_fields_for_publishing.each do |field|
            result = self.send(field)
            
            if result.kind_of? Array
              if !result.name.eql?(self.main_caller)
                result.select { |r| r.class.respond_to?(:required_fields_for_publishing) && !r.published?}.each do |r|
                  r.main_caller = self.main_caller
                  r.publish
                end
              end
            elsif result.class.respond_to?(:required_fields_for_publishing) && !result.published? && !result.class.name.eql?(self.main_caller)
              result.main_caller = self.main_caller
              result.publish
            end
          end
        else
          self.class.required_fields_for_publishing.each do |field|
            result = self.send(field)           
            if result.kind_of? Array
              if !result.name.eql?(self.main_caller)
                result.select { |r| r.class.respond_to?(:required_fields_for_publishing) && !r.published?}.each do |r|
                  r.main_caller = self.main_caller
                  r.reset
                end
              end
            elsif result.class.respond_to?(:required_fields_for_publishing) && !result.published? && !result.class.name.eql?(self.main_caller)
              result.main_caller = self.main_caller
              result.reset             
            end
          end
        end
      else
        self.class.required_fields_for_publishing.each do |field|
          result = self.send(field)
          
          if result.kind_of? Array
            if !result.name.eql?(self.main_caller)
              result.select { |r| r.class.respond_to?(:required_fields_for_publishing)}.each do |r|
                r.main_caller = self.main_caller
                r.validate_readiness 
              end
            end
          elsif result.class.respond_to?(:required_fields_for_publishing) && !result.class.name.eql?(self.main_caller)
            result.main_caller = self.main_caller
            result.validate_readiness 
          end
        end         
      end
      
      save if (!read_attribute(self.class.status_column).eql?(old_status) && !is_on_save)

      readiness_errors
    end
  end
end

ActiveRecord::Base.send :include, Publishable