class Comment < ActiveRecord::Base

  scope :published, :conditions => "comments.status = 'published'"
  scope :unpublished, :conditions => "comments.status not in ('published','abusive')"

  scope :published_and_abusive, :conditions => "comments.status in ('published','abusive')"
  scope :deleted, :conditions => "comments.status = 'deleted'"
  scope :flagged, :conditions => "flags_count > 0"
    
  scope :last_three_days, :conditions => "comments.created_at > '#{Time.now-3.days}'"
  scope :by_recently_created, :order => "comments.created_at desc"  
  scope :by_first_created, :order => "comments.created_at asc"  
  scope :by_recently_updated, :order => "comments.updated_at desc"  
  
  belongs_to :user
  belongs_to :activity
  
  has_many :notifications, :as => :notifiable, :dependent => :destroy
  
  validates_presence_of :content

  define_index do
    indexes content
    indexes activity.priority.category.name, :facet=>true
    where "comments.status = 'published'"
  end
  
  # docs: http://www.vaporbase.com/postings/stateful_authentication
  acts_as_state_machine :initial => :published, :column => :status
  
  state :published, :enter => :do_publish
  state :deleted, :enter => :do_delete  
  state :abusive, :enter => :do_abusive
  
  event :delete do
    transitions :from => :published, :to => :deleted
  end
  
  event :undelete do
    transitions :from => :deleted, :to => :published
  end  
  
  event :abusive do
    transitions :from => :published, :to => :abusive
  end
  
  def do_publish
    self.activity.changed_at = Time.now
    self.activity.comments_count += 1
    self.activity.save(:validate => false)
    self.user.increment!("comments_count")
    for u in activity.followers
      if u.id != self.user_id and not Following.find_by_user_id_and_other_user_id_and_value(u.id,self.user_id,-1)
        notifications << NotificationComment.new(:sender => self.user, :recipient => u)
      end
    end
    if self.activity.comments_count == 1 # this is the first comment, so need to update the discussions_count as appropriate
      if self.activity.has_point? 
        Point.update_all("discussions_count = discussions_count + 1", "id=#{self.activity.point_id}")
      end
      if self.activity.has_document?
        Document.update_all("discussions_count = discussions_count + 1", "id=#{self.activity.document_id}")
      end
      if self.activity.has_priority?
        Priority.update_all("discussions_count = discussions_count + 1", "id=#{self.activity.priority_id}")
        if self.activity.priority.attribute_present?("cached_issue_list")
          for issue in self.activity.priority.issues
            issue.increment!(:discussions_count)
          end
        end        
      end
    end
    self.activity.followings.find_or_create_by_user_id(self.user_id)
    return if self.activity.user_id == self.user_id or (self.activity.class == ActivityBulletinProfileNew and self.activity.other_user_id = self.user_id and self.activity.comments_count < 2) # they are commenting on their own activity
    if exists = ActivityCommentParticipant.find_by_user_id_and_activity_id(self.user_id,self.activity_id)
      exists.increment!("comments_count")
    else
      ActivityCommentParticipant.create(:user => self.user, :activity => self.activity, :comments_count => 1, :is_user_only => true)
    end
  end
  
  def do_delete
    if self.activity.comments_count == 1
      self.activity.changed_at = self.activity.created_at
    else
      self.activity.changed_at = self.activity.comments.published.by_recently_created.first.created_at
    end
    self.activity.comments_count -= 1
    self.save(:validate => false)    

    self.user.decrement!("comments_count")
    if self.activity.comments_count == 0
      if self.activity.has_point? and self.activity.point
        self.activity.point.decrement!(:discussions_count)
      end
      if self.activity.has_document? and self.activity.document
        self.activity.document.decrement!(:discussions_count)
      end
      if self.activity.has_priority? and self.activity.priority
        self.activity.priority.decrement!(:discussions_count)
        if self.activity.priority.attribute_present?("cached_issue_list")
          for issue in self.activity.priority.issues
            issue.decrement!(:discussions_count)
          end
        end
      end      
    end
    return if self.activity.user_id == self.user_id    
    exists = ActivityCommentParticipant.find_by_user_id_and_activity_id(self.user_id,self.id)
    if exists and exists.comments_count > 1
      exists.decrement!(:comments_count)
    elsif exists
      exists.delete!
    end
    for n in notifications
      n.delete!
    end
  end
  
  def do_abusive
    self.user.do_abusive!(notifications)
    self.update_attribute(:flags_count, 0)
  end
  
  def request=(request)
    self.ip_address = request.remote_ip
    self.user_agent = request.env['HTTP_USER_AGENT']
    self.referrer = request.env['HTTP_REFERER']
  end
  
  def parent_name 
    if activity.has_point?
      user.login + ' commented on ' + activity.point.name
    elsif activity.has_document?
      user.login + ' commented on ' + activity.document.name
    elsif activity.has_priority?
      user.login + ' commented on ' + activity.priority.name
    else
      user.login + ' posted a bulletin'
    end    
  end
  
  def flag_by_user(user)
    self.increment!(:flags_count)
    for r in User.active.admins
      Rails.logger.debug("Processing admin: #{r}")
      notifications << NotificationCommentFlagged.new(:sender => user, :recipient => r)    
      Rails.logger.debug("Notifications: #{notifications}")
    end
  end
  
  def show_url
    Government.current.homepage_url + 'activities/' + activity_id.to_s + '/comments#' + id.to_s
  end
  
  auto_html_for(:content) do
    html_escape
    youtube(:width => 330, :height => 210)
    vimeo(:width => 330, :height => 180)
    link :target => "_blank", :rel => "nofollow"
  end
  
end
