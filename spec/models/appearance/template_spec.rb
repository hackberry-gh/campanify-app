require 'spec_helper'

describe Appearance::Template do
  it "resolver returns a template with the saved body" do
    resolver = Appearance::Template::Resolver.instance
    details  = { :formats => [:html],  :handlers => [:erb], :locale => [:en] }
    resolver.find_all("layouts", "application", false, details).should be_empty
    Appearance::Template.create!({
      :body => "<%= 'hi from db template' %>",
      :path => "layouts/application",
      :format => "html",
      :handler => "erb",
      :locale => "en",
      :partial => false
    })
    template = resolver.find_all("application", "layouts", false, details).first
    template.should be_a_kind_of(ActionView::Template)
  
    template.source.should eql("<%= 'hi from db template' %>")
    template.handler.class.should eql(ActionView::Template::Handlers::ERB)
    template.formats.should eql([:html])
    template.virtual_path.should eql("layouts/application")
  end
  
  it "renders partial template" do
    k = Appearance::Template.create!({
      :body => "<%= 'hi from db template' %>",
      :path => "shared/header",
      :format => "html",
      :handler => "erb",
      :locale => "en",
      :partial => true
    })
    
    resolver = Appearance::Template::Resolver.instance
    details  = { :formats => [:html],  :handlers => [:erb], :locale => [:en] }
    template = resolver.find_all("header", "shared", true, details).first
    template.should be_a_kind_of(ActionView::Template)
  
    template.source.should eql("<%= 'hi from db template' %>")
    template.handler.class.should eql(ActionView::Template::Handlers::ERB)
    template.formats.should eql([:html])
    template.virtual_path.should eql("shared/_header")
  end
  
  it "template expires the cache on update" do
    
    Appearance::Template.create!({
      :body => "<%= 'hi from db template' %>",
      :path => "layouts/application",
      :format => "html",
      :handler => "erb",
      :locale => "en",
      :partial => false
    })
  
    cache_key = Object.new
    resolver = Appearance::Template::Resolver.instance
    details = { :formats => [:html],  :handlers => [:erb], :locale => [:en] }
    t = resolver.find_all("application", "layouts", false, details, cache_key).first 
    t.source.should eql("<%= 'hi from db template' %>")
  
    template = Appearance::Template.first
    template.update_attributes(body: "New body for template")
    t = resolver.find_all("application", "layouts", false, details, cache_key).first
    t.source.should eql("New body for template")
  end
end
