require 'rails_generator'
require 'rails_generator/commands'

module Publishable #:nodoc:
  module Generator #:nodoc:
    module Commands #:nodoc:
      module Create
        def publishing
          @name = args[0] ? args[0] : ""
          @name = @name.titlecase.gsub(" ", "")
          @name_downcase = @name.titlecase.gsub(" ", "_").downcase
          @image_prepend = @name.blank? ? "" : "#{@name_downcase}/"
          @view_prepend = @image_prepend
          #create controllers
          directory File.join('app/controllers', @name_downcase)
          template 'controller.rb',File.join('app/controllers', @name_downcase, "publishing_controller.rb")
          
          #create_helper
          template 'publishable_helper.rb', File.join("vendor/plugins/acts_as_publishable/lib/publishable", "publishable_helper.rb"), :collision => :force
         
          #create views
          directory File.join('app/views', @name_downcase, "publishing")
          template "_publishing_status.rhtml", File.join('app/views', @name_downcase, "publishing", "_publishing_status.rhtml"),:assigns => {:model => "ActiveRecord::base"}
          template "_publishing_tooltip.rhtml", File.join('app/views', @name_downcase, "publishing", "_publishing_tooltip.rhtml")
          template "_tooltip_publishing_status.rhtml", File.join('app/views', @name_downcase, "publishing", "_tooltip_publishing_status.rhtml")
          
          #images
          directory File.join('public/images', @name_downcase, "publishing")
          file "not_ready.png", File.join('public/images', @name_downcase, "publishing", "not_ready.png")
          file "not_ready_small.png", File.join('public/images', @name_downcase, "publishing", "not_ready_small.png")
          file "ready.png", File.join('public/images', @name_downcase, "publishing", "ready.png")
          file "ready_small.png", File.join('public/images', @name_downcase, "publishing", "ready_small.png") 
          file "published.png", File.join('public/images', @name_downcase, "publishing", "published.png")
          file "published_small.png", File.join('public/images', @name_downcase, "publishing", "published_small.png")
          file "archived.png", File.join('public/images', @name_downcase, "publishing", "archived.png")
          file "archived_small.png", File.join('public/images', @name_downcase, "publishing", "archived_small.png")
          file "arrow.png", File.join('public/images', @name_downcase, "publishing", "arrow.png")
          
          #tests
          directory File.join('test/functional', @name_downcase)         
          template 'controller_test.rb',File.join('test/functional', @name_downcase, "publishing_controller_test.rb")
         
          
          if !@name.eql?("")
            map_routes = 
<<-END
  # acts_as_publishable routes.
  map.with_options :controller => "#{@name_downcase}/publishing", :path_prefix => "#{@name_downcase}" do |#{@name_downcase}_publishable|
    #{@name_downcase}_publishable.publish "publish/:class/:id" , :action => "publish", :conditions => { :method => :post }
    #{@name_downcase}_publishable.unpublish "unpublish/:class/:id" , :action => "unpublish", :conditions => { :method => :post }
    #{@name_downcase}_publishable.archive "archive/:class/:id" , :action => "archive", :conditions => { :method => :post }
    #{@name_downcase}_publishable.reset "reset/:class/:id" , :action => "reset", :conditions => { :method => :post }
    #{@name_downcase}_publishable.readiness "readiness/:class/:id" , :action => "readiness", :conditions => { :method => :post }
  end
END
          else
            map_routes = 
<<-END
  # acts_as_publishable routes.
  map.with_options :controller => "publishing" do |publishable|
    publishable.publish "publish/:class/:id" , :action => "publish", :conditions => { :method => :post }
    publishable.unpublish "unpublish/:class/:id" , :action => "unpublish", :conditions => { :method => :post }
    publishable.archive "archive/:class/:id" , :action => "archive", :conditions => { :method => :post }
    publishable.reset "reset/:class/:id" , :action => "reset", :conditions => { :method => :post }
    publishable.readiness "readiness/:class/:id" , :action => "readiness", :conditions => { :method => :post }
  end
END
          end
          
          look_for = 'ActionController::Routing::Routes.draw do |map|'
          
          unless options[:pretend]
            gsub_file('config/routes.rb', /(#{Regexp.escape(look_for)})/mi) do |match| 
            "#{match}\n\n#{map_routes}\n"
            end
          end
        end 
      end
      
      module Destroy
        
        def publishing
          @name = args[0] ? args[0] : ""
          @name_downcase = @name.downcase
          if !@name.eql?("")
            map_routes = 
<<-END
  # acts_as_publishable routes.
  map.with_options :controller => "#{@name_downcase}/publishing", :path_prefix => "#{@name_downcase}" do |#{@name_downcase}_publishable|
    #{@name_downcase}_publishable.publish "publish/:class/:id" , :action => "publish", :conditions => { :method => :post }
    #{@name_downcase}_publishable.unpublish "unpublish/:class/:id" , :action => "unpublish", :conditions => { :method => :post }
    #{@name_downcase}_publishable.archive "archive/:class/:id" , :action => "archive", :conditions => { :method => :post }
    #{@name_downcase}_publishable.reset "reset/:class/:id" , :action => "reset", :conditions => { :method => :post }
    #{@name_downcase}_publishable.readiness "readiness/:class/:id" , :action => "readiness", :conditions => { :method => :post }
  end
END
          else
            map_routes = 
<<-END
  # acts_as_publishable routes.
  map.with_options :controller => "publishing" do |publishable|
    publishable.publish "publish/:class/:id" , :action => "publish", :conditions => { :method => :post }
    publishable.unpublish "unpublish/:class/:id" , :action => "unpublish", :conditions => { :method => :post }
    publishable.archive "archive/:class/:id" , :action => "archive", :conditions => { :method => :post }
    publishable.reset "reset/:class/:id" , :action => "reset", :conditions => { :method => :post }
    publishable.readiness "readiness/:class/:id" , :action => "readiness", :conditions => { :method => :post }
  end
END
          end
          #          logger.route "map.publishing_route"
          gsub_file 'config/routes.rb', map_routes, ''
        end
      end
      
      module List
        def publishing
        end
      end
      
      module Update
        def publishing
        end
      end
      
      
    end
  end
end

Rails::Generator::Commands::Create.send   :include,  Publishable::Generator::Commands::Create
Rails::Generator::Commands::Destroy.send  :include,  Publishable::Generator::Commands::Destroy
Rails::Generator::Commands::List.send     :include,  Publishable::Generator::Commands::List
Rails::Generator::Commands::Update.send   :include,  Publishable::Generator::Commands::Update
