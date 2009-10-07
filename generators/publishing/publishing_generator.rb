class PublishingGenerator < Rails::Generator::Base
  def manifest
    record do |m|
       m.publishing
#       m.publishable_route
    end
  end
end
