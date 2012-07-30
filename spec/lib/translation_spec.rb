require 'spec_helper'

Translation = I18n::Backend::ActiveRecord::Translation

describe Translation do

  it "fallbacks into simple backend if translation record not available" do
    I18n.locale = :en
    I18n.t('hello').should eq("Hello world")
  end

  it "supports dynamic creation" do
    I18n.backend.store_translations('en',{'foo' => 'bar'})
    I18n.t('foo').should eq('bar')
  end

  it 'supports arrays' do
    I18n.backend.store_translations('en',{'array' => ['first', 'second', 'last']})    
    I18n.t('array').should eq(['first', 'second', 'last'])
  end

  it 'supports interpolations' do
    I18n.backend.store_translations('en',{'interpol' => 'Hi %{name}!'})    
    I18n.t('interpol', name: "Onur").should eq("Hi Onur!")
  end  

  it 'supports dot notation' do
    I18n.backend.store_translations('en',{'key1.key2.key3' => 'me is key3'}, :escape => false)        
    I18n.t('key1').should eq({:"key2" => { :"key3" => "me is key3"}})
    I18n.t('key1.key2').should eq({:"key3" => "me is key3"})
    I18n.t('key1.key2.key3').should eq("me is key3")
  end

end
