xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Nýjustu erindin á vidraedur.is"
    xml.description ""
    xml.link url_for
    for document in @documents
      xml.item do
        xml.title document.name
        xml.pubDate document.created_at.to_s(:rfc822)
        xml.author document.user.login if document.user
        xml.link document_url(document)
      end
    end
  end
end