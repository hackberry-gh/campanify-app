module UsersHelper
  def users
		@users
	end
	
	def user
		@user || current_user
	end
end
