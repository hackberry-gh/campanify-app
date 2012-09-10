class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new # guest user (not logged in)
    if user.is_a?(Administrator)
      case user.role
      when "root"
        can :manage, :all        
      when "developer"
        can :manage, :all
        cannot :manage, [Administrator, Campaign, Settings]
      when "editor"  
        cannot :manage, :all
        can :manage, [Content::Event, Content::Media, Content::Page, 
                      Content::Post, Content::Widget ]
      end
    else
      # cancan not implemented for front end user model
    end
    
  end
end
