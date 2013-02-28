ActiveAdmin.register User do
  controller.authorize_resource  
  menu :if => proc{ can?(:read, User) }
  actions :index, :show, :edit, :update, :destroy
  index do
    selectable_column
    column :full_name
    column :email
    column :language
    column :country
    column :branch  
    column :popularity
    default_actions          
  end
  form do |f|
    f.inputs do
      f.input :email
      f.input :first_name
      f.input :last_name
      f.input :full_name
      f.input :display_name
      f.input :birth_year
      f.input :birth_date
      f.input :gender
      f.input :country, :as => :string
      f.input :region
      f.input :city
      f.input :address
      f.input :post_code
      f.input :phone
      f.input :mobile_phone
      f.input :branch
      f.input :language
      f.input :send_updates
      f.input :legal_aggrement
      f.input :provider
      f.input :uid
      f.input :avatar, :as => :file,
              :hint => f.object.avatar ? image_tag(f.object.avatar.thumb) : ""
    end
    f.buttons
  end

  collection_action :import_csv, :method => :post # TODO: report active admin bug
  collection_action :import_csv do
    if request.post?
      unless params[:users] 
        redirect_to import_csv_admin_users_path, alert: "CSV file required"
      else
        # uploader = CsvUploader.new
        # uploader.store!(params[:users][:csv])
        # Campanify::CSVImporter.delay.import(uploader.file.filename, User, :email)
        if CsvImport.create(file: params[:users][:csv], model: "User", uniq_field: "email")
          redirect_to import_csv_admin_users_path, notice: "CSV file uploaded successfully"
        else
          redirect_to import_csv_admin_users_path, alert: "CSV file has not been uploaded"
        end
      end
    end
  end
  
  action_item :only => :index do
    link_to 'Import from CSV', import_csv_admin_users_path
  end
end
