class Tag < ActiveRecord::Base

  extend ActiveSupport::Memoizable
    
  named_scope :by_endorsers_count, :order => "tags.up_endorsers_count desc"

  named_scope :alphabetical, :order => "tags.name asc"
  
  named_scope :most_webpages, :conditions => "tags.webpages_count > 0", :order => "tags.webpages_count desc"  
  named_scope :most_feeds, :conditions => "tags.feeds_count > 0", :order => "tags.feeds_count desc"   

  named_scope :item_limit, lambda{|limit| {:limit=>limit}}

  has_many :activities, :dependent => :destroy
  has_many :taggings
  has_many :priorities, :through => :taggings, :source => :priority, :conditions => "taggings.taggable_type = 'Priority'"
  has_many :webpages, :through => :taggings, :source => :webpage, :conditions => "taggings.taggable_type = 'Webpage'"
  has_many :feeds, :through => :taggings, :source => :feed, :conditions => "taggings.taggable_type = 'Feed'"
                              
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :within => 1..60
  validates_length_of :title, :within => 1..60, :allow_blank => true, :allow_nil => true
  
  cattr_reader :per_page
  @@per_page = 15  
  
  before_save :update_slug
  
  after_create :expire_cache
  after_destroy :expire_cache
  
  def expire_cache
    Tag.expire_cache
  end
  
  def Tag.expire_cache
    Rails.cache.delete('Tag.by_endorsers_count.all')
  end
  
  def update_slug
    self.slug = self.to_url
    self.title = self.name unless self.attribute_present?("title")
  end
  
  def to_url
    "#{name.parameterize_full[0..60]}"
  end

  def to_s
    name
  end
  
  def self.all_dropdown_options
    out = ""
    Tag.all.each do |t|
      out+="<option>#{t.name}</option>"
    end
    out
  end
  
  # LIKE is used for cross-database case-insensitivity
  def self.find_or_create_with_like_by_name(name)
    find(:first, :conditions => ["name LIKE ?", name]) || create(:name => name)
  end
  
  def ==(object)
    super || (object.is_a?(Tag) && name == object.name)
  end
    
  def count
    read_attribute(:count).to_i
  end
  
  def prompt_display
    return prompt if attribute_present?("prompt")
    return Government.current.prompt
  end
  
  def published_priority_ids
    Priority.published.tagged_with(self.name, :on => :issues).collect{|p| p.id}
  end
  memoize :published_priority_ids  
  
  def calculate_discussions_count
    Activity.active.discussions.for_all_users.by_recently_updated.count(:conditions => ["priority_id in (?)",published_priority_ids])
  end
  
  def calculate_questions_count
    Question.published.count(:conditions => ["priority_id in (?)",published_priority_ids])
  end  
  
  def calculate_documents_count
    Document.published.count(:conditions => ["priority_id in (?)",published_priority_ids])
  end
  
  def update_counts
    self.priorities_count = priorities.published.count
    self.documents_count = calculate_documents_count
    self.questions_count = calculate_questions_count
    self.discussions_count = calculate_discussions_count
  end  
  
  def has_top_priority?
    attribute_present?("top_priority_id")
  end    
end
