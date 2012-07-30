ActiveAdmin.register Content::Event do
  menu :parent => "Content"  
  
  index do
    column :name
    column :fb_id do |event|
      if event.fb_id
        link_to "http://facebook.com/events/#{event.fb_id}"
      else
        "N/A"  
      end
    end
    column :start_time
    column :location
    default_actions    
  end
  
  form :partial => "form"
end
