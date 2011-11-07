class FixCommentContentHtml < ActiveRecord::Migration
  class Helper
    include Singleton
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::TagHelper
  end

  def self.help
    Helper.instance
  end


  def self.up
    #Comment.transaction do
    #  Comment.all.each do |comment|
    #    comment.content_html = help.simple_format(comment.content_html)
    #    comment.save
    #  end
    #end
  end

  def self.down
  end
end
