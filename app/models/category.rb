class Category < ActiveRecord::Base
  has_many :priorities
  
  def i18n_name
    I18n.t(self.name)
  end
end
