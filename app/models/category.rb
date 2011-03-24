class Category < ActiveRecord::Base
  has_many :priorities
  
  def i18n_name
    tr(self.name, "model/category")
  end
end
