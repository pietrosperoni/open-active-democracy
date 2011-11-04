# coding: utf-8

require './crawler_utils'

class TagsParser
  def self.get_tags(html_doc)
    millivis_addr = html_doc.xpath("/html/body/table/tr[2]/td/table/tr/td[2]/div/p/a[1]")[0]['href']
    html_doc = CrawlerUtils.fetch_html("http://www.althingi.is#{millivis_addr}")
    tags_to_collect = []
    (html_doc/"div.AlmTexti").each do |top|
      if top.text.index("Efnisorð")
        (top/"li/a").each do |tag_link|
          tags_to_collect << tag_link.text.gsub(", "," og ")
        end
      end
    end
    tags_to_collect
  end
end
