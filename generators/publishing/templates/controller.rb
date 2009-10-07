class <%=@name.blank? ? "" : "#{@name}::" %>PublishingController < ApplicationController
  before_filter :get_model  
  
  def publish
    @model.publish
    @model.reload
    div_id = @model.respond_to?(:publish_div_id) ? "#{@model.publish_div_id}_readiness_messages" : "#{@model.class.name.downcase}_readiness_messages"
    
    render :update do |page|
      page[div_id].replace :partial => '<%=@view_prepend %>publishing/publishing_status', :locals => { :model => @model }
      page << "try { publishingListener(); } catch(e) { /* Do nothing */ }"
    end
    
  end
  
  def unpublish
    @model.unpublish
    @model.reload
    div_id = @model.respond_to?(:publish_div_id) ? "#{@model.publish_div_id}_readiness_messages" : "#{@model.class.name.downcase}_readiness_messages"
    
    render :update do |page|
      page[div_id].replace :partial => '<%=@view_prepend %>publishing/publishing_status', :locals => { :model => @model }
      page << "try { unpublishingListener(); } catch(e) { /* Do nothing */ }"
    end
    
  end
  
  def reset
    @model.reset
    @model.reload
    div_id = @model.respond_to?(:publish_div_id) ? "#{@model.publish_div_id}_readiness_messages" : "#{@model.class.name.downcase}_readiness_messages"
    
    render :update do |page|
      page[div_id].replace :partial => '<%=@view_prepend %>publishing/publishing_status', :locals => { :model => @model }
      page << "try { resetListener(); } catch(e) { /* Do nothing */ }"
    end
    
  end
  
  
  def archive
    @model.archive
    @model.reload
    div_id = @model.respond_to?(:publish_div_id) ? "#{@model.publish_div_id}_readiness_messages" : "#{@model.class.name.downcase}_readiness_messages"
    
    render :update do |page|
      page[div_id].replace :partial => '<%=@view_prepend %>publishing/publishing_status', :locals => { :model => @model }
      page << "try { archiveListener(); } catch(e) { /* Do nothing */ }"
    end
    
  end
  
  def readiness
    render :update do |page|

      page["readiness_messages_#{@model.class.name}_#{@model.id}"].replace_html :partial => '<%=@view_prepend %>publishing/publishing_tooltip', :locals => { :model => @model }
      page["#{@model.class.name}_#{@model.id}_tooltip"].show
    end
  end
  
  protected
  
  def get_model
    @model = Class.const_get(params[:class]).find(params[:id]) if params[:class] && params[:id]
  end
end