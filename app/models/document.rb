class Document < ActiveRecord::Base
  scope :tagged, :conditions => "(documents.cached_issue_list is not null and documents.cached_issue_list <> '')"
  scope :by_tag_name, lambda{|tag_name| {:conditions=>["cached_issue_list=?",tag_name]}}
  scope :by_user_id, lambda{|user_id| {:conditions=>["user_id=?",user_id]}}

  scope :flagged, :conditions => "flags_count > 0"

  acts_as_taggable_on :issues
  acts_as_set_partner :table_name=>"documents"

  scope :published, :conditions => "documents.status = 'published'"
  scope :unpublished, :conditions => "documents.status not in ('published','abusive')"

  scope :by_helpfulness, :order => "documents.score desc"
  scope :by_endorser_helpfulness, :conditions => "documents.endorser_score > 0", :order => "documents.endorser_score desc"
  scope :by_neutral_helpfulness, :conditions => "documents.neutral_score > 0", :order => "documents.neutral_score desc"    
  scope :by_opposer_helpfulness, :conditions => "documents.opposer_score > 0", :order => "documents.opposer_score desc"
  scope :up, :conditions => "documents.endorser_score > 0"
  scope :neutral, :conditions => "documents.neutral_score > 0"
  scope :down, :conditions => "documents.opposer_score > 0"  

  scope :by_recently_created, :order => "documents.created_at desc"
  scope :by_recently_updated, :order => "documents.updated_at desc"  
  scope :revised, :conditions => "revisions_count > 1"
  scope :since, lambda{|time| {:conditions=>["documents.created_at>?",time]}}

  has_many :notifications, :as => :notifiable, :dependent => :destroy

  belongs_to :user
  belongs_to :priority
  belongs_to :revision, :class_name => "DocumentRevision", :foreign_key => "revision_id" # the current revision
  
  has_many :revisions, :class_name => "DocumentRevision", :dependent => :destroy
  has_many :activities, :dependent => :destroy, :order => "activities.created_at desc"
  
  has_many :author_users, :through => :revisions, :select => "distinct users.*", :source => :user, :class_name => "User"
  
  has_many :qualities, :class_name => "DocumentQuality", :order => "created_at desc", :dependent => :destroy
  has_many :helpfuls, :class_name => "DocumentQuality", :conditions => "value = 1", :order => "created_at desc"
  has_many :unhelpfuls, :class_name => "DocumentQuality", :conditions => "value = 0", :order => "created_at desc"
  
  has_many :capitals, :as => :capitalizable, :dependent => :nullify
  
  define_index do
    indexes name
    indexes content
    indexes priority.category.name, :facet=>true
    where "documents.status = 'published'"    
  end
  
  cattr_reader :per_page
  @@per_page = 25
  
  def to_param
    "#{id}-#{name.parameterize_full}"
  end  
  
  def activity
    # HACK TO ENABLE THINKING SPHINX TO GET THROUGH... NEED TO FIND THE REAL CAUSE
    self
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
    self.user.do_abusive!(notifications)
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
    priority.save(:validate => false) if priority
  end
  
  def do_delete
    remove_counts
    activities.each do |a|
      a.delete!
    end
    # look for any capital they may have earned on this document, and remove it
    capital_earned = capitals.sum(:amount)
    if capital_earned != 0
      self.capitals << CapitalDocumentHelpfulDeleted.new(:recipient => user, :amount => (capital_earned*-1))
    end
    priority.save(:validate => false)
    for r in revisions
      r.delete!
    end
  end
  
  def do_bury
    remove_counts
    priority.save(:validate => false) if priority
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
    "[#{tr("Against", "model/document")}] " + name
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
  
  def is_up?
    value > 0
  end
  
  def is_down?
    value < 0
  end
  
  def is_neutral?
    value == 0
  end

  def is_published?
    ['published'].include?(status)
  end
  alias :is_published :is_published?
  
  def calculate_score(tosave=false,current_endorsement=nil)
    old_score = self.score
    old_endorser_score = self.endorser_score
    old_opposer_score = self.opposer_score
    old_neutral_score = self.neutral_score
    self.score = 0
    self.endorser_score = 0
    self.opposer_score = 0
    self.neutral_score = 0
    for q in qualities.find(:all, :include => :user)
      if q.is_helpful?
        vote = q.user.quality_factor
      else
        vote = -q.user.quality_factor
      end
      self.score += vote
      if q.is_endorser?
        self.endorser_score += vote
      elsif q.is_opposer?
        self.opposer_score += vote        
      else
        self.neutral_score += vote
      end
    end
    if self.opposer_score > 1 and old_opposer_score <= 1
      capitals << CapitalDocumentHelpfulOpposers.new(:recipient => user, :amount => 1)  
    end    
    if self.endorser_score > 1 and old_endorser_score <= 1
      capitals << CapitalDocumentHelpfulEndorsers.new(:recipient => user, :amount => 1)
    end    
    if self.neutral_score > 1 and old_neutral_score <= 1
      capitals << CapitalDocumentHelpfulUndeclareds.new(:recipient => user, :amount => 1)
    end        
    
    if self.endorser_score < -0.5 and old_endorser_score >= -0.5
      endorsement = current_endorsement || Endorsement.find_by_user_id_and_priority_id(self.user_id, self.priority_id)
      if endorsement and endorsement.is_up?
        capitals << CapitalDocumentHelpfulEndorsers.new(:recipient => user, :amount => -1)
      end
    end
    if self.opposer_score < -0.5 and old_opposer_score >= -0.5
      endorsement = current_endorsement || Endorsement.find_by_user_id_and_priority_id(self.user_id, self.priority_id)
      if endorsement and endorsement.is_down?
        capitals << CapitalDocumentHelpfulOpposers.new(:recipient => user, :amount => -1)
      end
    end
    if self.neutral_score < -0.5 and old_neutral_score >= -0.5
      endorsement = current_endorsement || Endorsement.find_by_user_id_and_priority_id(self.user_id, self.priority_id)
      if not endorsement
        capitals << CapitalDocumentHelpfulUndeclareds.new(:recipient => user, :amount => -1)
      end
    end
    
    if self.opposer_score > 1 and self.endorser_score > 1 and (old_opposer_score <= 1 or old_endorser_score <= 1)
      capitals << CapitalDocumentHelpfulEveryone.new(:recipient => user, :amount => 1)
    end      
    if self.opposer_score < -0.5 and self.endorser_score < -0.5 and (old_opposer_score >= -0.5 or old_endorser_score >= -0.5)
      capitals << CapitalDocumentHelpfulEveryone.new(:recipient => user, :amount => -1)        
    end    

    if old_score != self.score and tosave
      self.save(:validate => false)
    end    
  end
  
  def opposers_helpful?
    opposer_score > 0
  end
  
  def endorsers_helpful?
    endorser_score > 0    
  end
  
  def neutrals_helpful?
    neutral_score > 0    
  end  

  def everyone_helpful?
    score > 0    
  end
  
  def is_deleted?
    status == 'deleted'
  end
  
  def helpful_endorsers_capital_spent
    capitals.sum(:amount, :conditions => "type = 'CapitalDocumentHelpfulEndorsers'")
  end

  def helpful_opposers_capital_spent
    capitals.sum(:amount, :conditions => "type = 'CapitalDocumentHelpfulOpposers'")
  end
  
  def helpful_undeclareds_capital_spent
    capitals.sum(:amount, :conditions => "type = 'CapitalDocumentHelpfulUndeclareds'")
  end  
  
  def helpful_everyone_capital_spent
    capitals.sum(:amount, :conditions => "type = 'CapitalDocumentHelpfulEveryone'")
  end  

  def priority_name
    priority.name if priority
  end
  
  def priority_name=(n)
    self.priority = Priority.find_by_name(n) unless n.blank?
  end

  def show_url
    Government.current.homepage_url + 'documents/' + to_param
  end

  auto_html_for(:content) do
    html_escape
    youtube(:width => 460, :height => 285)
    vimeo(:width => 460, :height => 260)
    link :target => "_blank", :rel => "nofollow"
  end

end
