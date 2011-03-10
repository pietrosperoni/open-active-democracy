class Category < ActiveRecord::Base
  has_many :priorities
  
  def i18n_name
    tr("translation missing: en.nil", "model/category")
  end
end
