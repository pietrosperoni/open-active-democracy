class Tr8n::IsoCountry < ActiveRecord::Base
  set_table_name :tr8n_iso_countries
  has_and_belongs_to_many :languages, :class_name => 'Tr8n::Language', :foreign_key => "tr8n_iso_country_id", :association_foreign_key=>"tr8n_language_id", :join_table=>"tr8n_iso_countries_tr8n_languages"
  scope :by_name, :order=>"country_english_name"
  belongs_to :partner

  EU_AND_EEA_COUNTRIES = ["at", "be", "bg", "cy", "cz", "dk", "ee", "fi", "fr", "de", "gr", "hu", "ie", "it", "lv", "lt", "lu", "mt", "nl", "pl", "pt", "ro", "sk", "si", "es", "se", "gb","is","no","li","ch"]

  def self.country_in_eu_or_eea?(country_code)
    EU_AND_EEA_COUNTRIES.include?(country_code.downcase)
  end

  def large_flag_image
    base_flag_url(64)
  end

  def medium_flag_image
    base_flag_url(32)
  end

  def small_flag_image
    base_flag_url(24)
  end

  def tiny_flag_image
    base_flag_url(16)
  end
  
  def base_flag_url(size)
    "flags/#{size}/#{self.code.downcase}.png"
  end
  
  def self.all_countries_in_columns
    one = []
    two = []
    three = []
    four = []
    five = []
    six = []
    flip = 1
    self.by_name.all.each do |a|
      if flip==1
        one << a
        flip = 2
      elsif flip==2
        two << a
        flip = 3
      elsif flip==3
        three << a
        flip = 4
      elsif flip==4
        four << a
        flip = 5
      elsif flip==5
        five << a
        flip = 6
      elsif flip==6
        six << a
        flip = 1
      end
    end
    [one,two,three,four,five,six]
  end
end
