# coding: utf-8

class TagsParser
  def self.get_tags(html_doc,tags_to_collect)
    millivis_addr = html_doc.xpath("/html/body/table/tr[2]/td/table/tr/td[2]/div/p/a[1]")[0]['href']
    html_doc = open(URI.encode("http://www.althingi.is#{millivis_addr}")).read

    # The HTML is encoded in the document's source encoding. Tidy's 'raw'
    # mode sucks, and there seems to be no way for Tidy to detect the
    # encoding, so we ensure that Tidy always gets UTF-8 data
    html_doc.encode!('UTF-8')
    Tidy.open({ "char-encoding" => "utf8", "wrap" => 0 }) do |tidy|
      html_doc = tidy.clean(html_doc)
    end
    html_doc = Nokogiri::HTML(html_doc)
    (html_doc/"div.AlmTexti").each do |top|
      if top.text.index("Efnisorð")
        (top/"li/a").each do |tag_link|
          tags_to_collect << tag_link.text.gsub(", "," og ")
        end
      end
    end
    tags_to_collect.join(", ")
  end
end
