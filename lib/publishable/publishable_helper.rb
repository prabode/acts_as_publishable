# publishable_helper generated by act_as_publishable
module PublishableHelper
  include ActionView::Helpers::AssetTagHelper   

  def publishing_status_tag(model, authentication_token)
    if model.published?
      image_tag("admin/publishing/published_small.png")
    elsif model.ready?
      image_tag("admin/publishing/ready_small.png")
    elsif model.archived?
      image_tag("admin/publishing/archived_small.png")
    else

      readiness_url = readiness_path(:class => model.class.name, :id => model.id, :authenticity_token => authentication_token)

    content = 
<<-Tooltip
<style>
.tooltip {
position: absolute;
background-image: url(/images/admin/publishing/arrow.png);
background-repeat: no-repeat;
}
.tooltip_content {
padding: 20px;
margin-top: 20px;
background-color: #fdf389;
}
</style>
<span id="#{model.class.name}_#{model.id}_tooltip_link">#{image_tag("admin/publishing/not_ready_small.png",:border=>"0",:style=>'cursor:help')}</span>
<script type="text/javascript">
//<![CDATA[
$('#{model.class.name}_#{model.id}_tooltip_link').observe('click', function(event){new Ajax.Request('#{readiness_url}');toggleTooltip(event, $('#{model.class.name}_#{model.id}_tooltip'))});
//]]>
</script>
<div class="tooltip" id="#{model.class.name}_#{model.id}_tooltip" style="display: none;">
<div class="tooltip_content" id="#{model.class.name}_#{model.id}_tooltip_content">
<div id="readiness_messages_#{model.class.name}_#{model.id}">Loading...</div>
<a href="#" onclick="$('#{model.class.name}_#{model.id}_tooltip').hide(); return false;">close</a>
</div>
</div>
Tooltip
    end
  end
end

def publishing_actions_tag(model)
  render :partial => 'admin/publishing/publishing_status', :locals => { :model => model }
end

ActionController::Base.helper PublishableHelper