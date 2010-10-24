class Activity < ActiveRecord::Base
    
  named_scope :active, :conditions => "activities.status = 'active'"
  named_scope :deleted, :conditions => "activities.status = 'deleted'", :order => "updated_at desc"
  named_scope :for_all_users, :conditions => "is_user_only=false"

  named_scope :discussions, :conditions => "activities.comments_count > 0"
  named_scope :questions, :conditions => "type like 'ActivityQuestion%'", :order => "activities.created_at desc"
  named_scope :questions_and_docs, :conditions => "type like 'ActivityQuestion%' or type like 'ActivityDocument%'", :order => "activities.created_at desc"
  
  named_scope :by_recently_updated, :order => "activities.changed_at desc"  
  named_scope :by_recently_created, :order => "activities.created_at desc"    

  named_scope :no_unanswered_questions, :conditions=>"unanswered_question = 0 AND (priority_id IS NOT NULL OR question_id IS NOT NULL OR document_id IS NOT NULL)"

  named_scope :item_limit, lambda{|limit| {:limit=>limit}}

  named_scope :by_tag_name, lambda{|tag_name| {:conditions=>["cached_issue_list=?",tag_name]}}

  named_scope :by_user_id, lambda{|user_id| {:conditions=>["user_id=?",user_id]}}

  acts_as_taggable_on :issues
  
  belongs_to :user
  
  belongs_to :other_user, :class_name => "User", :foreign_key => "other_user_id"
  belongs_to :priority
  belongs_to :activity
  belongs_to :tag
  belongs_to :question
  belongs_to :revision
  belongs_to :document
  belongs_to :document_revision
  
  has_many :comments, :order => "comments.created_at asc", :dependent => :destroy
  has_many :published_comments, :class_name => "Comment", :foreign_key => "activity_id", :conditions => "comments.status = 'published'", :order => "comments.created_at asc"
  has_many :commenters, :through => :published_comments, :source => :user, :select => "DISTINCT users.*"
  has_many :activities, :dependent => :destroy
  has_many :notifications, :as => :notifiable, :dependent => :destroy
  has_many :followings, :class_name => "FollowingDiscussion", :foreign_key => "activity_id", :dependent => :destroy
  has_many :followers, :through => :followings, :source => :user, :select => "DISTINCT users.*"
  
  liquid_methods :name, :id, :first_comment, :last_comment
  
  # docs: http://www.vaporbase.com/postings/stateful_authentication
  acts_as_state_machine :initial => :active, :column => :status

  before_save :update_changed_at
  
  def update_changed_at
    self.changed_at = Time.now unless self.attribute_present?("changed_at")
  end
  
  state :active
  state :deleted, :enter => :do_delete
  
  event :delete do
    transitions :from => :active, :to => :deleted
  end
  
  event :undelete do
    transitions :from => :deleted, :to => :active
  end

  def multi_name
    return "test x"
    if self.priority_id
      self.priority.name
    elsif self.question_id
      self.question.name
    elsif self.document_id
      self.document.name
    else
      "#{self.inspect}"
    end
  end

  def show_multi_url
    return "test m"
    if self.priority_id
      self.priority.show_url
    elsif self.question_id
      self.question.show_url
    elsif self.document_id
      self.document.show_url
    else
      "#{self.inspect}"
    end
  end

  def do_delete
    # go through and mark all the comments as deleted
    for comment in published_comments
      comment.delete!
    end
  end

  cattr_reader :per_page
  @@per_page = 25

  def commenters_count
    comments.count(:group => :user, :order => "count_all desc")
  end  

  def is_official_user?
    return false unless Government.last.has_official?
    user_id == Government.last.official_user_id
  end

  def has_priority?
    attribute_present?("priority_id")
  end
  
  def has_activity?
    attribute_present?("activity_id")
  end
  
  def has_user?
    attribute_present?("user_id")
  end    
  
  def has_other_user?
    attribute_present?("other_user_id")
  end  
  
  def has_question?
    attribute_present?("question_id")
  end
    
  def has_revision?
    attribute_present?("revision_id")
  end    
  
  def has_document?
    attribute_present?("document_id")
  end  
  
  def has_document_revision?
    attribute_present?("document_revision_id")
  end  
  
  def has_comments?
    comments_count > 0
  end
  
  def first_comment
    comments.published.first
  end
  
  def last_comment
    comments.published.last
  end
  
end

class ActivityUserNew < Activity
  def name
    I18n.t('activity.user.new.name', :user_name => user.name, :government_name => Government.last.name)
  end
end

# Jerry invited Jonathan to join
class ActivityInvitationNew < Activity
  def name
    if user 
      I18n.t('activity.invitation.new.name', :user_name => user.login)
    else
      I18n.t('activity.invitation.new.name', :user_name => "Someone")
    end
  end
end

# Jonathan accepted Jerry's invitation to join
class ActivityInvitationAccepted < Activity
  def name
    if other_user
      I18n.t('activity.invitation.accepted.name.known', :user_name => user.name, :other_user_name => other_user.name, :government_name => Government.last.name)
    else
      I18n.t('activity.invitation.accepted.name.unknown', :user_name => user.name, :government_name => Government.last.name)
    end
  end  
end

# Jerry recruited Jonathan to White House 2.
class ActivityUserRecruited < Activity
  
  after_create :add_capital
  
  def add_capital
    ActivityCapitalUserRecruited.create(:user => user, :other_user => other_user, :capital => CapitalUserRecruited.new(:recipient => user, :amount => 5))
  end
  
  def name
    I18n.t('activity.user.recruited.name', :user_name => user.name, :other_user_name => other_user.name, :government_name => Government.last.name)
  end
end

class ActivityCapitalUserRecruited < Activity
  def name
    I18n.t('activity.capital.user.recruited.name', :user_name => user.name, :other_user_name => other_user.name, :government_name => Government.last.name, :capital => capital.amount.abs, :currency_short_name => Government.last.currency_short_name)    
  end
end

class ActivityPriorityDebut < Activity
  
  def name
    if attribute_present?("position")
      I18n.t('activity.priority.debut.name.known', :priority_name => priority.name, :position => position)
    else
      I18n.t('activity.priority.debut.name.unknown', :priority_name => priority.name)
    end
  end
  
end

class ActivityPriorityNew < Activity
  def name
    I18n.t('activity.priority.new.name', :user_name => user.name, :priority_name => priority.name)     
  end  
end

# [user name] flagged [priority name] as inappropriate.
class ActivityPriorityFlagInappropriate < Activity
  
  def name
    I18n.t('activity.priority.flagged.name', :user_name => user.name, :priority_name => priority.name)     
  end  
  
  validates_uniqueness_of :user_id, :scope => [:priority_id], :message => "You've already flagged this."
  
end

class ActivityPriorityFlag < Activity
  
  def name
    I18n.t('activity.priority.flagged.name', :user_name => user.name, :priority_name => priority.name)  
  end  

  after_create :notify_admin
  
  def notify_admin
    for r in User.active.admins
      priority.notifications << NotificationPriorityFlagged.new(:sender => user, :recipient => r) if r.id != user.id
    end
  end
  
end

# [user name] buried [priority name].
class ActivityPriorityBury < Activity
  def name
    I18n.t('activity.priority.buried.name', :user_name => user.name, :priority_name => priority.name)  
  end
end

# identifies that a person is participating in a discussion about another activity
# is_user_only!  it's not meant to be shown on the priority page, just on the user page
# and it's only supposed to be invoked once, when they first start discussing an activity
# but the updated_at should be updated on subsequent postings in the discussion
class ActivityCommentParticipant < Activity
 
  def name
    I18n.t('activity.comment.participant.name', :user_name => user.name, :count => comments_count, :discussion_name => activity.name)  
  end
  
end

class ActivityDiscussionFollowingNew < Activity
  def name
    I18n.t('activity.discussion.following.new.name', :user_name => user.name, :discussion_name => activity.name)
  end
end

class ActivityDiscussionFollowingDelete < Activity
  def name
    I18n.t('activity.discussion.following.delete.name', :user_name => user.name, :discussion_name => activity.name)
  end
end

class ActivityPriorityCommentNew < Activity
  def name
    I18n.t('activity.priority.comment.new.name', :user_name => user.name, :priority_name => priority.name)  
  end
end

class ActivityBulletinProfileNew < Activity
  
  after_create :send_notification
  
  def send_notification
    notifications << NotificationProfileBulletin.new(:sender => self.other_user, :recipient => self.user)       
  end
  
  def name
    I18n.t('activity.bulletin.profile.new.name', :user_name => other_user.name, :other_user_name => user.name.possessive)  
  end
  
end

class ActivityBulletinProfileAuthor < Activity
  
  def name
    I18n.t('activity.bulletin.profile.new.name', :user_name => user.name, :other_user_name => other_user.name.possessive)      
  end
  
end

class ActivityBulletinNew < Activity
  
  def name
    if question
      I18n.t('activity.bulletin.new.name.known', :user_name => user.name, :discussion_name => question.name)         
    elsif document
      I18n.t('activity.bulletin.new.name.known', :user_name => user.name, :discussion_name => document.name)
    elsif priority
      I18n.t('activity.bulletin.new.name.known', :user_name => user.name, :discussion_name => priority.name)
    else
      I18n.t('activity.bulletin.new.name.unknown', :user_name => user.name)
    end
  end
  
end

class ActivityPriority1 < Activity
  def name
    I18n.t('activity.priority.first.endorsed.name', :user_name => user.name.possessive, :priority_name => priority.name)
  end
end

class ActivityPriority1Opposed < Activity
  def name
    I18n.t('activity.priority.first.opposed.name', :user_name => user.name.possessive, :priority_name => priority.name)
  end
end

class ActivityPriorityRising1 < Activity
  def name
    I18n.t('activity.priority.rising.name', :priority_name => priority.name)
  end
end

class ActivityIssuePriority1 < Activity
  def name
    I18n.t('activity.priority.tag.first.name', :priority_name => priority.name, :tag_name => tag.title)
  end
end

class ActivityIssuePriorityControversial1 < Activity
  def name
    I18n.t('activity.priority.tag.controversial.name', :priority_name => priority.name, :tag_name => tag.title)
  end
end

class ActivityIssuePriorityRising1 < Activity
  def name
    I18n.t('activity.priority.tag.rising.name', :priority_name => priority.name, :tag_name => tag.title)
  end
end

class ActivityPriorityRenamed < Activity
  def name
    I18n.t('activity.priority.renamed.name', :user_name => user.name, :priority_name => priority.name)  
  end
end

class ActivityQuestionNew < Activity
  
  def name
    I18n.t('activity.question.new.name', :user_name => user.name, :point_name => question.name, :priority_name => priority.name)      
  end
  
end

class ActivityQuestionDeleted < Activity
  def name
    I18n.t('activity.question.deleted.name', :user_name => user.name, :point_name => question.name)      
  end
end

class ActivityQuestionRevisionContent < Activity
  def name
    I18n.t('activity.question.revision.content.name', :user_name => user.name, :point_name => question.name)      
  end
end

class ActivityQuestionRevisionName < Activity
  def name
    I18n.t('activity.question.revision.name', :user_name => user.name, :point_name => question.name)
  end
end

class ActivityQuestionRevisionWebsite < Activity
  def name
    if revision.has_website?
      I18n.t('activity.question.revision.website.new.name', :user_name => user.name, :point_name => question.name)
    else
      I18n.t('activity.question.revision.website.deleted.name', :user_name => user.name, :point_name => question.name)
    end
  end
end

class ActivityQuestionRevisionSupportive < Activity
  def name
    I18n.t('activity.question.revision.supportive.name', :user_name => user.name, :point_name => question.name, :priority_name => priority.name)    
  end
end

class ActivityQuestionRevisionNeutral < Activity
  def name
    I18n.t('activity.question.revision.neutral.name', :user_name => user.name, :point_name => question.name, :priority_name => priority.name)    
  end
end

class ActivityQuestionRevisionOpposition < Activity
  def name
    I18n.t('activity.question.revision.opposition.name', :user_name => user.name, :point_name => question.name, :priority_name => priority.name)    
  end
end

class ActivityQuestionHelpful < Activity
  def name
    I18n.t('activity.question.helpful.name', :user_name => user.name, :point_name => question.name)    
  end
end

class ActivityQuestionUnhelpful < Activity
  def name
    I18n.t('activity.question.unhelpful.name', :user_name => user.name, :point_name => question.name)    
  end
end

class ActivityQuestionHelpfulDelete < Activity
  def name
    I18n.t('activity.question.helpful.delete.name', :user_name => user.name, :point_name => question.name)    
  end
end

class ActivityQuestionUnhelpfulDelete < Activity
  def name
    I18n.t('activity.question.unhelpful.delete.name', :user_name => user.name, :point_name => question.name)    
  end
end

class ActivityUserPictureNew < Activity
  def name
    I18n.t('activity.user.picture.new.name', :user_name => user.name)
  end
end

class ActivityIgnoringNew < Activity
  def name
    I18n.t('activity.ignoring.new.name', :user_name => user.name, :other_user_name => other_user.name)
  end
end

class ActivityIgnoringDelete < Activity
  def name
    I18n.t('activity.ignoring.delete.name', :user_name => user.name, :other_user_name => other_user.name)
  end
end

class ActivityDocumentNew < Activity
  
  def name
    I18n.t('activity.question.new.name', :user_name => user.name, :point_name => document.name, :priority_name => priority.name)
  end
  
end

class ActivityDocumentDeleted < Activity
  def name
    I18n.t('activity.question.deleted.name', :user_name => user.name, :point_name => document.name)      
  end
end

class ActivityDocumentRevisionContent < Activity
  def name
    I18n.t('activity.question.revision.content.name', :user_name => user.name, :point_name => document.name)      
  end
end

class ActivityDocumentRevisionName < Activity
  def name
    I18n.t('activity.question.revision.name', :user_name => user.name, :point_name => document.name)
  end
end

class ActivityDocumentRevisionSupportive < Activity
  def name
    I18n.t('activity.question.revision.supportive.name', :user_name => user.name, :point_name => document.name, :priority_name => priority.name)    
  end
end

class ActivityDocumentRevisionNeutral < Activity
  def name
    I18n.t('activity.question.revision.neutral.name', :user_name => user.name, :point_name => document.name, :priority_name => priority.name)    
  end
end

class ActivityDocumentRevisionOpposition < Activity
  def name
    I18n.t('activity.question.revision.opposition.name', :user_name => user.name, :point_name => document.name, :priority_name => priority.name)    
  end
end

class ActivityDocumentHelpful < Activity
  def name
    I18n.t('activity.question.helpful.name', :user_name => user.name, :point_name => document.name)    
  end
end

class ActivityDocumentUnhelpful < Activity
  def name
    I18n.t('activity.question.unhelpful.name', :user_name => user.name, :point_name => document.name)    
  end
end

class ActivityDocumentHelpfulDelete < Activity
  def name
    I18n.t('activity.question.helpful.delete.name', :user_name => user.name, :point_name => document.name)    
  end
end

class ActivityDocumentUnhelpfulDelete < Activity
  def name
    I18n.t('activity.question.unhelpful.delete.name', :user_name => user.name, :point_name => document.name)    
  end
end

class ActivityUserProbation < Activity
  def name
    I18n.t('activity.user.probation.name', :user_name => user.name)
  end
end