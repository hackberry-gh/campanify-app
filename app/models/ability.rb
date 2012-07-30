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
        cannot :manage, [Campaign, Admin, Settings]
      when "editor"  
        cannot :manage, :all
        can :manage, [Content::Event, Content::Medium, Content::Page, 
                      Content::Post, Content::Widget, 
                      I18n::Backend::Mongoid::Translation  ]
      end
    else
      can :read, :all
      can :manage, Content::Post, {:user_id => user.id} if Settings.user['abilities']['can_post']
    end
    
  end
end
