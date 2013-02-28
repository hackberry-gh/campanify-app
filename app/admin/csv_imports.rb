ActiveAdmin.register CsvImport do
  controller.authorize_resource  
  menu :priority => 999, :if => proc{ can?(:read, CsvImport) }
  actions :index, :show, :create, :new, :destroy
  index do
    selectable_column
    column :filename
    column :created_at
    default_actions          
  end
  show do |csv_import|
		attributes_table do
      row :filename
      row :results do
        content_tag :pre, "#{csv_import.results}"
      end
      row :created_at      
      row :updated_at            
    end
    active_admin_comments
  end
  form do |f|
    f.inputs do 
      f.input :file, as: :file
      f.input :model, as: :select, collection: [User]
      f.input :uniq_field, :hint => "email, etc"
    end
    f.actions
  end
end