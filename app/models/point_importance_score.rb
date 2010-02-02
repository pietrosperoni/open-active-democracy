class PointImportanceScore < ActiveRecord::Base
	belongs_to :user
	belongs_to :point
	
	def self.calculate_score(point_id)
		return self.average(:importance_score, :conditions=>["point_id = ?", point_id])
	end
	
	def self.has_voted?(point_id, user_id)
		self.find(:all, :conditions=>["point_id = ? AND user_id = ?", point_id, user_id]).length > 0
	end
	
	def self.update_or_create(point_id, user_id, score)
		if self.has_voted?(point_id, user_id)
			p = self.find(:first, :conditions=>["point_id = ? AND user_id = ?", point_id, user_id])
		else
			p = self.new
		end
		p.point_id = point_id
		p.user_id = user_id
		p.importance_score = score
		p.save
	end
end
