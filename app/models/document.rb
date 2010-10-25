class Document < ActiveRecord::Base
  named_scope :tagged, :conditions => "(documents.cached_issue_list is not null and documents.cached_issue_list <> '')"
  named_scope :by_tag_name, lambda{|tag_name| {:conditions=>["cached_issue_list=?",tag_name]}}
  named_scope :by_user_id, lambda{|user_id| {:conditions=>["user_id=?",user_id]}}

  named_scope :flagged, :conditions => "flags_count > 0"

  acts_as_taggable_on :issues

  named_scope :published, :conditions => "documents.status = 'published'"

  named_scope :by_recently_created, :order => "documents.created_at desc"
  named_scope :by_recently_updated, :order => "documents.updated_at desc"  
  named_scope :revised, :conditions => "revisions_count > 1"

  has_many :notifications, :as => :notifiable, :dependent => :destroy

  belongs_to :user
  belongs_to :priority
  belongs_to :revision, :class_name => "DocumentRevision", :foreign_key => "revision_id" # the current revision
  
  has_many :revisions, :class_name => "DocumentRevision", :dependent => :destroy
  has_many :activities, :dependent => :destroy, :order => "activities.created_at desc"
  
  has_many :author_users, :through => :revisions, :select => "distinct users.*", :source => :user, :class_name => "User"
  
  liquid_methods :id, :text, :user

  define_index do
    indexes name
    indexes content
    indexes cached_issue_list, :facet=>true
    where "status = 'published'"
  end
  
  cattr_reader :per_page
  @@per_page = 25
  
  def to_param
    "#{id}-#{name.parameterize_full}"
  end  
  
  after_destroy :delete_document_quality_activities
  before_destroy :remove_counts
  before_save :update_word_count
  
  validates_length_of :name, :within => 3..60
  validates_uniqueness_of :name  
  
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

  def update_word_count
    self.word_count = self.content.split(' ').length
  end

  def do_publish
    self.published_at = Time.now
    add_counts
    priority.save_with_validation(false) if priority
  end
  
  def do_delete
    remove_counts
    activities.each do |a|
      a.delete!
    end
    for r in revisions
      r.delete!
    end
  end
  
  def do_bury
    remove_counts
    priority.save_with_validation(false) if priority
  end
  
  def add_counts
    if priority
      priority.up_documents_count += 1 if is_up?
      priority.down_documents_count += 1 if is_down?
      priority.neutral_documents_count += 1 if is_neutral?        
      priority.documents_count += 1
    end
    user.increment!(:documents_count)
  end
  
  def remove_counts
    if priority
      priority.up_documents_count -= 1 if is_up?
      priority.down_documents_count -= 1 if is_down?
      priority.neutral_documents_count -= 1 if is_neutral?        
      priority.documents_count -= 1
    end
    user.decrement!(:documents_count)    
  end
  
  def delete_document_quality_activities
    qs = Activity.find(:all, :conditions => ["document_id = ? and type in ('ActivityDocumentHelpfulDelete','ActivityDocumentUnhelpfulDelete')",self.id])
    for q in qs
      q.destroy
    end
  end

  def name_with_type
    return name unless is_down?
    "[á móti] " + name
  end

  def text
    name_with_type + "\r\n" + content
  end

  def has_priority?
    attribute_present?("priority_id")
  end

  def authors
    revisions.count(:group => :user, :order => "count_all desc")
  end
  
  def editors
    revisions.count(:group => :user, :conditions => ["document_revisions.user_id <> ?", user_id], :order => "count_all desc")
  end  
  def is_published?
    ['published'].include?(status)
  end
  alias :is_published :is_published?
  
  def is_deleted?
    status == 'deleted'
  end
  
  def priority_name
    priority.name if priority
  end
  
  def priority_name=(n)
    self.priority = Priority.find_by_name(n) unless n.blank?
  end

  def show_url
    Government.last.homepage_url + 'documents/' + to_param
  end

  auto_html_for(:content) do
    redcloth
    youtube(:width => 460, :height => 285)
    vimeo(:width => 460, :height => 260)
    link(:rel => "nofollow")
  end

end
