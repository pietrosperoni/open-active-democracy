class TreatyDocument < ActiveRecord::Base

  MAXIMUM_NUMBER_OF_DOCUMENTS = 25
 
  named_scope :by_category, lambda{|category| {:conditions=>["category=?",category]}}
  named_scope :by_negotiation_status, lambda{|negotiation_status| {:conditions=>["negotiation_status=?",negotiation_status]}}
  named_scope :latest_three, :limit=>3, :order=>"date DESC"

  named_scope :s9, :conditions=>"negotiation_status = 9 AND chapter = 36 AND category = 'F1_4'"

  named_scope :since, lambda{|time| {:conditions=>["date>?",time]}}

  acts_as_taggable_on :issues

  NEGOTIATION_STAGES = [
                     {:id=>0, :name=>"Umsókn"},
                     {:id=>1, :name=>"Upphaf viðræðna"},
                     {:id=>2, :name=>"Rýnivinna"},
                     {:id=>3, :name=>"Samningsafstaða Íslands"},
                     {:id=>4, :name=>"Opnun kafla"},
                     {:id=>5, :name=>"Lokun kafla"},
                     {:id=>6, :name=>"Aðildarsamningur"}
          ]
  
  def tag_name
    if self.chapter==36
      "Allir kaflar"
    else
      self.cached_issue_list
    end
  end
end
