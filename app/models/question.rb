class Question < ActiveRecord::Base
  named_scope :tagged, :conditions => "(questions.cached_issue_list is not null and questions.cached_issue_list <> '')"
  named_scope :by_tag_name, lambda{|tag_name| {:conditions=>["cached_issue_list=?",tag_name]}}
  named_scope :by_user_id, lambda{|user_id| {:conditions=>["user_id=?",user_id]}}

  named_scope :by_subfilter, lambda{|filter| filter==nil ? nil : filter=="answered" ? {:conditions=>"answer IS NOT NULL"} : {:conditions=>"answer IS NULL"} }

  named_scope :flagged, :conditions => "flags_count > 0"

  acts_as_taggable_on :issues

  has_many :notifications, :as => :notifiable, :dependent => :destroy

  named_scope :published, :conditions => "questions.status = 'published'"
  named_scope :by_recently_created, :order => "questions.created_at desc"
  named_scope :by_recently_updated, :order => "questions.updated_at desc"  
  named_scope :revised, :conditions => "revisions_count > 1"
  named_scope :five, :limit => 5

  belongs_to :user
  belongs_to :revision # the current revision
  
  has_many :revisions, :dependent => :destroy
  has_many :activities, :dependent => :destroy, :order => "activities.created_at desc"
  
  has_many :author_users, :through => :revisions, :select => "distinct users.*", :source => :user, :class_name => "User"
  
  define_index do
    indexes name
    indexes content
    indexes answer
    indexes cached_issue_list, :facet=>true
    where "status = 'published'"    
  end

  liquid_methods :id, :name, :activity_id, :content, :user, :activity, :show_url, :text
  
  cattr_reader :per_page
  @@per_page = 15  
  
  def to_param
    "#{id}"
  end  
    
#  validates_length_of :name, :within => 3..100
  #validates_uniqueness_of :name
  # this is actually just supposed to be 500, but bumping it to 510 because the javascript counter doesn't include carriage returns in the count, whereas this does.
  #validates_length_of :content, :maximum => 1100, :allow_blank => true, :allow_nil => true, :too_long => I18n.t("questions.new.errors.content_maximum")
  
  # docs: http://www.practicalecommerce.com/blogs/post/122-Rails-Acts-As-State-Machine-Plugin
  acts_as_state_machine :initial => :published, :column => :status
  
  state :draft
  state :published, :enter => :do_publish
  state :deleted, :enter => :do_delete
  state :buried, :enter => :do_bury
  state :abusive, :enter => :do_abusive

  
  event :publish do
    transitions :from => [:draft], :to => :published
  end
  
  event :delete do
    transitions :from => [:draft, :published,:buried], :to => :deleted
  end

  event :undelete do
    transitions :from => :deleted, :to => :published, :guard => Proc.new {|p| !p.published_at.blank? }
    transitions :from => :deleted, :to => :draft 
  end
  
  event :bury do
    transitions :from => [:draft, :published, :deleted], :to => :buried
  end
  
  event :unbury do
    transitions :from => :buried, :to => :published, :guard => Proc.new {|p| !p.published_at.blank? }
    transitions :from => :buried, :to => :draft     
  end  

  event :abusive do
    transitions :from => :published, :to => :abusive
  end

  def do_abusive
    self.user.do_abusive!
    self.update_attribute(:flags_count, 0)
  end

  def flag_by_user(user)
    self.increment!(:flags_count)
    for r in User.active.admins
      notifications << NotificationCommentFlagged.new(:sender => user, :recipient => r)    
    end
  end

  def do_publish
    self.published_at = Time.now
  end
  
  def do_delete
    activities.each do |a|
      a.delete!
    end
    for r in revisions
      r.delete!
    end
  end
  
  def do_bury
  end
  
  def add_counts
  end
  
  def remove_counts
  end
  
  def delete_question_quality_activities
  end

  def name_with_type
  end

  def text
    s = name_with_type
    return s
  end

  def authors
    revisions.count(:group => :user, :order => "count_all desc")
  end
  
  def editors
    revisions.count(:group => :user, :conditions => ["revisions.user_id <> ?", user_id], :order => "count_all desc")
  end  
    
  def is_deleted?
    status == 'deleted'
  end

  def is_published?
    ['published'].include?(status)
  end
  alias :is_published :is_published?
  
  def website_link
    return nil if self.website.nil?
    wu = website
    wu = 'http://' + wu if wu[0..3] != 'http'
    return wu    
  end  
  
  def show_url
    Government.last.homepage_url + 'questions/' + to_param
  end  
  
  auto_html_for(:content) do
    redcloth
    youtube(:width => 330, :height => 210)
    vimeo(:width => 330, :height => 180)
    link(:rel => "nofollow")
  end  
  
end
