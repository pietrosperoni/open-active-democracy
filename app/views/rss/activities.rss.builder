xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Nýtt frá vidraedur.is"
    xml.description ""
    xml.link url_for
    for activity in @activities
      if activity.priority_id or activity.class == ActivityQuestionNew or activity.class == ActivityDocumentNew
        xml.item do
          if activity.priority_id
            xml.title "Umræðuefni - #{activity.priority.name}"
            xml.pubDate activity.priority.created_at.to_s(:rfc822)
            xml.author activity.priority.user.login if activity.priority.user
            xml.link activity.priority.show_url
          elsif activity.class == ActivityQuestionNew
            xml.title "Spurning - #{activity.question.name}"
            xml.pubDate activity.question.created_at.to_s(:rfc822)
            xml.author activity.question.user.login if activity.question.user
            xml.link activity.question.show_url
          elsif activity.class == ActivityDocumentNew
            xml.title "Erindi - #{activity.document.name}"
            xml.pubDate activity.document.created_at.to_s(:rfc822)
            xml.author activity.document.user.login if activity.document.user
            xml.link activity.document.show_url
          end
        end
      end
    end
  end
end