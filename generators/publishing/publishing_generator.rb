class PublishingGenerator < Rails::Generator::Base
  def manifest
    record do |m|
       m.publishing
    end
  end
end
