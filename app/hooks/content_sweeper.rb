class ContentSweeper < ActionController::Caching::Sweeper
  include Jobs

  observe Content::Event if Settings.modules.include?("events")
  observe Content::Post if Settings.modules.include?("posts")
  observe Content::Media if Settings.modules.include?("media")
  observe Content::Page, Content::Widget

  def after_create(content)
    Delayed::Job.enqueue(Jobs::ContentSweeperJob.new(content.class.to_s,content.id,false), run_at: Time.now - 10.minutes)
  end

  def after_update(content)
    Delayed::Job.enqueue(Jobs::ContentSweeperJob.new(content.class.to_s,content.id,true), run_at: Time.now - 10.minutes)
  end

  def after_destroy(content)
    Delayed::Job.enqueue(Jobs::ContentSweeperJob.new(content.class.to_s,content.id,false), run_at: Time.now - 10.minutes)
  end

end
