# coding: utf-8

require '../../config/boot'
require "../../config/environment"

require 'nokogiri'
require 'tidy'
require 'open-uri'
require 'timeout'
require 'yaml'
require 'htmlentities'

TYPE_HEADER_MAIN = 1
TYPE_HEADER_CHAPTER= 2
TYPE_HEADER_MAIN_ARTICLE = 3
TYPE_HEADER_TEMPORARY_ARTICLE = 4
TYPE_HEADER_ESSAY = 5
TYPE_HEADER_COMMENTS_MAIN = 6
TYPE_HEADER_COMMENTS_ABOUT_CHAPTERS = 7
TYPE_HEADER_COMMENTS_ABOUT_MAIN_ARTICLES = 8
TYPE_HEADER_COMMENTS_ABOUT_TEMPORARY_ARTICLE = 9
TYPE_HEADER_COMMENTS_ABOUT_WHOLE_DOCUMENT = 10
TYPE_CHAPTER = 11
TYPE_MAIN_ARTICLE = 12
TYPE_TEMPORARY_ARTICLE = 13
TYPE_COMMENTS_ABOUT_CHAPTERS = 14
TYPE_COMMENTS_ABOUT_MAIN_ARTICLES = 15
TYPE_COMMENTS_ABOUT_TEMPORARY_ARTICLES = 16
TYPE_COMMENTS_ABOUT_WHOLE_DOCUMENT = 17
TYPE_HEADER_MAIN_CONTENT = 18
TYPE_ESSAY_MAIN_CONTENT = 19
TYPE_HEADER_REPORT_ABOUT_LAW = 20
TYPE_REPORT_ABOUT_LAW = 21

module CrawlerUtils
  @@translations = YAML.load_file('./althingi_categories.yml')
  @@category_mappings = {}
  @@seen_categories = {}
  @@seen_tags = {}
  @@seen_subtags = {}

  def self.get_process_category_id(id)
    return if not @@category_mappings[id]
    return @@category_mappings[id][:category_id]
  end

  def self.get_process_tag_names(id)
    return [] if not @@category_mappings[id]
    return @@category_mappings[id][:tag_names].keys
  end

  def self.fetch_html(url)
    retries = 10

    begin
      Timeout::timeout(120){
        puts "Downloading #{url}"
        html_source = open(url).read

        # The HTML is encoded in the document's source encoding. Tidy's 'raw'
        # mode sucks, and there seems to be no way for Tidy to detect the
        # encoding, so we ensure that Tidy always gets UTF-8 data
        html_source.encode!('UTF-8')

        # we need Tidy to fix improperly nested tags on althingi.is
        Tidy.open({ "char-encoding" => "utf8", "wrap" => 0 }) do |tidy|
          html_source = tidy.clean(html_source)
        end

        # preprocess the html if the caller desires
        yield(html_source) if block_given?

        return Nokogiri::HTML(html_source)
      }
    rescue
      retries -= 1
      if retries > 0
        sleep 0.42 and retry
      else
        raise
      end
    end
  end

  def self.update_categories
    category_page = CrawlerUtils.fetch_html('http://www.althingi.is/vefur/efnisflokkun.html')
    category_table = category_page.xpath('/html/body/table/tr[2]/td/table/tr/td/table[2]/tr/td[2]/div/center/table')

    category_table.search('tr').each do |row|
      top_category_cell, sub_category_cell = row.search('td')
      top_category = top_category_cell.text
      top_category.gsub!(/\u00a0/, '')
      if not @@translations[top_category]
        puts "Top category #{top_category} unknown"
        raise
      end
      top_category = @@translations[top_category]
      @@seen_categories[top_category] ||= Category.find_or_create_by_name(top_category).id
      @@seen_tags[top_category] ||= Tag.find_or_create_by_name(top_category).name

      sub_category_cell.search('a').each do |sub_category_link|
        sub_category = sub_category_link.text
        sub_category.gsub!(/\u00a0/, '')
        if not @@translations[sub_category]
          puts "Sub category #{sub_category} unknown"
          raise
        end
        sub_category = @@translations[sub_category]
        @@seen_tags[sub_category] ||= Tag.find_or_create_by_name(sub_category).name
        @@seen_subtags[top_category] ||= {}
        @@seen_subtags[top_category][sub_category] ||= self.add_category_subtag(@@seen_categories[top_category], sub_category)
        sub_category_url = "http://www.althingi.is/vefur/#{sub_category_link['href']}"
        sub_category_page = CrawlerUtils.fetch_html(sub_category_url)
        sub_category_table = sub_category_page.xpath("/html/body/table/tr[2]/td/table/tr/td/table[2]/tr/td[2]/div/table")

        processes = sub_category_table.search('tr')[1..-1].each do |row|
          process_number = row.at('td[1]').text
          @@category_mappings[process_number] ||= {}
          @@category_mappings[process_number][:category_id] = @@seen_categories[top_category]
          @@category_mappings[process_number][:tag_names] ||= {}
          @@category_mappings[process_number][:tag_names][ @@seen_tags[top_category] ] = true
          @@category_mappings[process_number][:tag_names][ @@seen_tags[sub_category] ] = true
        end
      end
    end
  end

  private

  def self.add_category_subtag(category_id, tag)
    category = Category.find(category_id)
    sub_tags = category.sub_tags
    sub_tags = sub_tags ? sub_tags.split(',') : []
    if (sub_tags - [tag]).size == sub_tags.size
      category.sub_tags = (sub_tags | [tag]).join(',')
      category.save
    end
    return true
  end
end
