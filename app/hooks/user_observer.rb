class UserObserver < ActiveRecord::Observer
  include Jobs

  observe User
  
  def after_create(user)
    Delayed::Job.enqueue(Jobs::UserHooksJob.new("after_create",user.id), run_at: Time.now - 10.minutes)
  end

  def after_update(user)
    Delayed::Job.enqueue(Jobs::UserHooksJob.new("after_update",user.id), run_at: Time.now - 10.minutes)
  end

  def after_delete(user)
    Delayed::Job.enqueue(Jobs::UserHooksJob.new("after_delete",user.id), run_at: Time.now - 10.minutes)
  end

  

end