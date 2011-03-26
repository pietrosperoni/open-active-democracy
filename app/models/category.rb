class Category < ActiveRecord::Base
  has_many :priorities
  
  def i18n_name
    tr(self.name, "model/category")
  end
  
  def self.for_partner
    if Partner.current and Category.where(:partner_id=>Partner.current.id).count > 0
      Category.where(:partner_id=>Partner.current.id).order("name")
    else
      Category.order("name")
    end
  end
end
