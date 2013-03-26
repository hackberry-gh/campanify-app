class UserSweeper < ActionController::Caching::Sweeper
  include Jobs
  
  observe User
  
  def after_create(user)
    Delayed::Job.enqueue(Jobs::UserSweeperJob.new(user.class.to_s,user.id,false), run_at: Time.now - 10.minutes)
  end

  def after_update(user)
    Delayed::Job.enqueue(Jobs::UserSweeperJob.new(user.class.to_s,user.id,true), run_at: Time.now - 10.minutes)
  end

  def after_destroy(user)
    Delayed::Job.enqueue(Jobs::UserSweeperJob.new(user.class.to_s,user.id,false), run_at: Time.now - 10.minutes)
  end
  
end