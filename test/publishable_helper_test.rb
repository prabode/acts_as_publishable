require File.dirname(__FILE__) + '/test_helper.rb'
require 'rails_generator'
require 'rails_generator/scripts/generate'

# This test needs the publishable_helper got created on acts_as_publishable/lib/publishable/publishable_helper.rb
# Therefore first run the generator and create the skeleton using the name "admin"
class PublisherbleHelperTest < Test::Unit::TestCase
  
  include PublishableHelper
  
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::CaptureHelper
  include ActionController::UrlWriter
  include ActionController::Assertions::SelectorAssertions
  
  def setup
    @controller = Class.new do
      def url_for(options)
        url =  "http://www.example.com/"
        url << options[:action].to_s if options and options[:action]
        url
      end
    end
    
    @controller = @controller.new
    @not_ready_publisher = get_publisher("not_ready")
    @ready_publisher = get_publisher("ready")
    @published_publisher = get_publisher("published")
    @archived_publisher = get_publisher("archived")
    @authentication_token = "abc"#ActiveSupport::SecureRandom.base64(32)
    
    FileUtils.mkdir_p(File.join(fake_rails_root, "config"))
    FileUtils.mkdir_p(File.join(fake_rails_root, "vendor/plugins/acts_as_publishable/lib/publishable"))
  end
  
  def teardown
    FileUtils.rm_r(fake_rails_root)
  end
  
  def test_for_ready_publisher
    assert_match /<img alt="Ready_small" src="\/images\/.*publishing\/ready_small\.png/, publishing_status_tag(@ready_publisher, @authentication_token)
  end
  
  def test_for_published_publisher
    assert_match /<img alt="Published_small" src="\/images\/.*publishing\/published_small\.png/, publishing_status_tag(@published_publisher, @authentication_token)
  end
  
  def test_for_archived_publisher
    assert_match /<img alt="Archived_small" src="\/images\/.*publishing\/archived_small\.png/, publishing_status_tag(@archived_publisher, @authentication_token)
  end
  
  def test_for_not_ready_publisher
    
    readiness_url = "/admin/readiness/#{@not_ready_publisher.class.name}/#{@not_ready_publisher.id}?authenticity_token=#{@authentication_token}"
    s =     
<<-Tooltip
<style>
.tooltip {
position: absolute;
background-image: url(/images/publishing/arrow.gif);
background-repeat: no-repeat;
}
.tooltip_content {
padding: 20px;
margin-top: 20px;
background-color: #fdf389;
}
</style>
<span id="#{@not_ready_publisher.class.name}_#{@not_ready_publisher.id}_tooltip_link">#{image_tag("admin/publishing/not_ready_small.png",:border=>"0",:style=>'cursor:help')}</span>
<script type="text/javascript">
//<![CDATA[
$('#{@not_ready_publisher.class.name}_#{@not_ready_publisher.id}_tooltip_link').observe('click', function(event){new Ajax.Request('#{readiness_url}');toggleTooltip(event, $('#{@not_ready_publisher.class.name}_#{@not_ready_publisher.id}_tooltip'))});
//]]>
</script>
<div class="tooltip" id="#{@not_ready_publisher.class.name}_#{@not_ready_publisher.id}_tooltip" style="display: none;">
<div class="tooltip_content" id="#{@not_ready_publisher.class.name}_#{@not_ready_publisher.id}_tooltip_content">
<div id="readiness_messages_#{@not_ready_publisher.class.name}_#{@not_ready_publisher.id}">Loading...</div>
<a href="#" onclick="$('#{@not_ready_publisher.class.name}_#{@not_ready_publisher.id}_tooltip').hide(); return false;">close</a>
</div>
</div>
Tooltip


    assert_match /<span id="#{@not_ready_publisher.class.name}_#{@not_ready_publisher.id}_tooltip_link">/, publishing_status_tag(@not_ready_publisher, @authentication_token)
    assert_match /#{image_tag("admin/publishing/not_ready_small.png",:border=>"0",:style=>'cursor:help').gsub(/./, "\.")}<\/span>/, publishing_status_tag(@not_ready_publisher, @authentication_token)
     
#    //<![CDATA[
#     $('#{@not_ready_publisher.class.name}_#{@not_ready_publisher.id}_tooltip_link').observe('click', function(event){new Ajax.Request('#{readiness_url}');toggleTooltip(event, $('#{@not_ready_publisher.class.name}_#{@not_ready_publisher.id}_tooltip'))});
#     //]]> 
#   Match of the above response organized in three asserts  
    assert_match /\$\('#{@not_ready_publisher.class.name}_#{@not_ready_publisher.id}_tooltip_link'\)/, publishing_status_tag(@not_ready_publisher, @authentication_token)
    assert_match /\.observe\('click', function\(event\)\{new Ajax\.Request\('.*\);/, publishing_status_tag(@not_ready_publisher, @authentication_token)
    assert_match /toggleTooltip\(event, \$\('#{@not_ready_publisher.class.name}_#{@not_ready_publisher.id}_tooltip'\)\)\}\);/, publishing_status_tag(@not_ready_publisher, @authentication_token)
    
    assert_match /<div class="tooltip" id="#{@not_ready_publisher.class.name}_#{@not_ready_publisher.id}_tooltip" style="display: none;">/, publishing_status_tag(@not_ready_publisher, @authentication_token)
    assert_match /<div class="tooltip_content" id="#{@not_ready_publisher.class.name}_#{@not_ready_publisher.id}_tooltip_content">/, publishing_status_tag(@not_ready_publisher, @authentication_token)
    assert_match /<div id="readiness_messages_#{@not_ready_publisher.class.name}_#{@not_ready_publisher.id}">Loading\.\.\.<\/div>/, publishing_status_tag(@not_ready_publisher, @authentication_token)
    assert_match /<a href="#" onclick="\$\('#{@not_ready_publisher.class.name}_#{@not_ready_publisher.id}_tooltip'\)\.hide\(\); return false;">close<\/a>/, publishing_status_tag(@not_ready_publisher, @authentication_token)

  end
  
  def get_publisher(status)
    publisher = Publisher.create
    
    return publisher if status == "not_ready"
    
    publisher.name = "rails"
    publisher.save
    if status == "ready"
      return publisher
    elsif status == "published"
      publisher.publish
      return publisher
    else
      publisher.archive
    end
    publisher
  end
  
  private
  
  def fake_rails_root
    File.join(File.dirname(__FILE__), "rails_root")
  end
  
  def routes_path
    File.join(fake_rails_root, "config", "routes.rb")
  end
end