class Revision < ActiveRecord::Base

  named_scope :published, :conditions => "revisions.status = 'published'"
  named_scope :by_recently_created, :order => "revisions.created_at desc"  

  belongs_to :question  
  belongs_to :user
  belongs_to :other_priority, :class_name => "Priority"
    
  has_many :activities
  has_many :notifications, :as => :notifiable, :dependent => :destroy
      
  # this is actually just supposed to be 500, but bumping it to 510 because the javascript counter doesn't include carriage returns in the count, whereas this does.
  validates_length_of :content, :maximum => 516, :allow_blank => true, :allow_nil => true, :too_long => I18n.t("questions.new.errors.content_maximum")
  
  liquid_methods :id, :user, :url, :text
  
  # docs: http://www.practicalecommerce.com/blogs/post/122-Rails-Acts-As-State-Machine-Plugin
  acts_as_state_machine :initial => :draft, :column => :status
  
  state :draft
  state :archived, :enter => :do_archive
  state :published, :enter => :do_publish
  state :deleted, :enter => :do_delete
  
  event :publish do
    transitions :from => [:draft, :archived], :to => :published
  end

  event :archive do
    transitions :from => :published, :to => :archived
  end
  
  event :delete do
    transitions :from => [:published, :archived], :to => :deleted
  end

  event :undelete do
    transitions :from => :deleted, :to => :published, :guard => Proc.new {|p| !p.published_at.blank? }
    transitions :from => :deleted, :to => :archived 
  end
  
  before_save :truncate_user_agent
  
  def truncate_user_agent
    self.user_agent = self.user_agent[0..149] if self.user_agent # some user agents are longer than 150 chars!
  end
  
  def do_publish
    self.published_at = Time.now
    self.auto_html_prepare
    begin
      Timeout::timeout(5) do   #times out after 5 seconds
        self.content_diff = HTMLDiff.diff(RedCloth.new(question.content).to_html,RedCloth.new(self.content).to_html)
      end
    rescue Timeout::Error
    end    
    question.revisions_count += 1    
    changed = false
    if question.revisions_count == 1
      ActivityQuestionNew.create(:user => user, :question => question, :revision => self)
    else
      if question.content != self.content # they changed content
        changed = true
        ActivityQuestionRevisionContent.create(:user => user, :question => question, :revision => self)
      end
      if question.website != self.website
        changed = true
        ActivityQuestionRevisionWebsite.create(:user => user, :question => question, :revision => self)
      end
      if question.name != self.name
        changed = true
        ActivityQuestionRevisionName.create(:user => user, :question => question, :revision => self)
      end
      if question.other_priority_id != self.other_priority_id
        changed = true
        ActivityQuestionRevisionOtherPriority.create(:user => user, :question => question, :revision => self)
      end
      if question.value != self.value
        changed = true
        if self.is_up?
          ActivityQuestionRevisionSupportive.create(:user => user,:question => question, :revision => self)
        elsif self.is_neutral?
          ActivityQuestionRevisionNeutral.create(:user => user,  :question => question, :revision => self)
        elsif self.is_down?
          ActivityQuestionRevisionOpposition.create(:user => user, :question => question, :revision => self)
        end
      end      
    end    
    if changed
      for a in question.author_users
        if a.id != self.user_id
          notifications << NotificationQuestionRevision.new(:sender => self.user, :recipient => a)    
        end
      end
    end    
    question.content = self.content
    question.website = self.website
    question.revision_id = self.id
    question.value = self.value
    question.name = self.name
    question.author_sentence = question.user.login
    question.author_sentence += ", breytingar " + question.editors.collect{|a| a[0].login}.to_sentence if question.editors.size > 0
    question.published_at = Time.now
    question.save_with_validation(false)
    user.increment!(:question_revisions_count)    
  end
  
  def do_archive
    self.published_at = nil
  end
  
  def do_delete
    question.decrement!(:revisions_count)
    user.decrement!(:question_revisions_count)    
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

  def priority_name
    priority.name if priority
  end
  
  def priority_name=(n)
    self.priority = Priority.find_by_name(n) unless n.blank?
  end
  
  def other_priority_name
    other_priority.name if other_priority
  end
  
  def other_priority_name=(n)
    self.other_priority = Priority.find_by_name(n) unless n.blank?
  end  
  
  def has_other_priority?
    attribute_present?("other_priority_id")
  end
  
  def text
    s = question.name
    s += " [á móti]" if is_down?
    s += " [hlutlaust]" if is_neutral?    
    s += "\r\nTil stuðnings " + question.other_priority.name if question.has_other_priority?
    s += "\r\n" + content
    s += "\r\nUppruni: " + website_link if has_website?
    return s
  end  
  
  def website_link
    return nil if self.website.nil?
    wu = website
    wu = 'http://' + wu if wu[0..3] != 'http'
    return wu    
  end  
  
  def has_website?
    attribute_present?("website")
  end  
  
  def request=(request)
    if request
      self.ip_address = request.remote_ip
      self.user_agent = request.env['HTTP_USER_AGENT']
    else
      self.ip_address = "127.0.0.1"
      self.user_agent = "Import"
    end
  end
  
  def Revision.create_from_question(question_id, request)
    p = Question.find(question_id)
    r = Revision.new
    r.question = p
    r.user = p.user
    r.value = p.value
    r.name = p.name
    r.content = p.content
    r.content_diff = p.content
    r.website = p.website    
    r.request = request
    r.save_with_validation(false)
    r.publish!
  end
  
  def url
    'http://' + Government.current.base_url + '/questions/' + question_id.to_s + '/revisions/' + id.to_s + '?utm_source=questions_changed&utm_medium=email'
  end  
  
  auto_html_for(:content) do
    redcloth
    youtube(:width => 330, :height => 210)
    vimeo(:width => 330, :height => 180)
    link(:rel => "nofollow")
  end  
  
end
