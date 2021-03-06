require File.dirname(__FILE__) + '/test_helper.rb'
require 'rails_generator'
require 'rails_generator/scripts/generate'
require 'rails_generator/scripts/destroy'

class PublishingGeneratorTest < Test::Unit::TestCase
  
  def setup
    FileUtils.mkdir_p(File.join(fake_rails_root, "config"))
    FileUtils.mkdir_p(File.join(fake_rails_root, "vendor/plugins/acts_as_publishable/lib/publishable"))
  end
  
  def teardown
    FileUtils.rm_r(fake_rails_root)
  end
  
  def test_generates_route
    content = 
<<-END
ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
END
    File.open(routes_path, 'wb') {|f| f.write(content) }
    
    Rails::Generator::Scripts::Generate.new.run(["publishing", "Admin"], :destination => fake_rails_root)
    assert_match /admin_publishable\.publish/, File.read(routes_path)
  
    assert_match /class Admin::PublishingController < ApplicationController/, File.read(File.join(fake_rails_root, "app/controllers/admin/publishing_controller.rb"))
    assert_match /<!--_publishing_status generated by act_as_publishable-->/, File.read(File.join(fake_rails_root, "app/views/admin/publishing/_publishing_status.rhtml"))
    assert_match /<!--_publishing_tooltip generated by act_as_publishable-->/, File.read(File.join(fake_rails_root, "app/views/admin/publishing/_publishing_tooltip.rhtml"))
    assert_match /<!--_tooltip_publishing_status generated by act_as_publishable-->/, File.read(File.join(fake_rails_root, "app/views/admin/publishing/_tooltip_publishing_status.rhtml"))
    assert_match /# publishable_helper generated by act_as_publishable/, File.read(File.join(fake_rails_root, "vendor/plugins/acts_as_publishable/lib/publishable/publishable_helper.rb"))

  end
  
  def test_destroys_route
    content = 
<<-END
ActionController::Routing::Routes.draw do |map|

  # acts_as_publishable routes.
  map.with_options :controller => "admin/publishing", :path_prefix => "admin" do |admin_publishable|
    admin_publishable.publish "publish/:class/:id" , :action => "publish", :conditions => { :method => :post }
    admin_publishable.unpublish "unpublish/:class/:id" , :action => "unpublish", :conditions => { :method => :post }
    admin_publishable.archive "archive/:class/:id" , :action => "archive", :conditions => { :method => :post }
    admin_publishable.reset "reset/:class/:id" , :action => "reset", :conditions => { :method => :post }
    admin_publishable.readiness "readiness/:class/:id" , :action => "readiness", :conditions => { :method => :post }
  end


  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
END
    File.open(routes_path, 'wb') {|f| f.write(content) }
    
    Rails::Generator::Scripts::Destroy.new.run(["publishing", "Admin"], :destination => fake_rails_root)
    assert_no_match /admin_publishable\.publish/, File.read(routes_path)
  end
  
  private
  
  def fake_rails_root
    File.join(File.dirname(__FILE__), "rails_root")
  end
  
  def routes_path
    File.join(fake_rails_root, "config", "routes.rb")
  end
  
end
