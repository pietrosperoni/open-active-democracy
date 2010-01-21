# Copyright (C) 2008,2009,2010 Róbert Viðar Bjarnason
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

#TODO: Cleanup this (quickly written) messy code

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'timeout'

#RAILS_ENV='production'
RAILS_ENV='development'

require '../../config/boot'
require "#{RAILS_ROOT}/config/environment"

#require '/home/robert/sites/open-direct-democracy/master/current/app/models/process_document_element.rb'
#require '/home/robert/sites/open-direct-democracy/master/current/app/models/process.rb'
#require '/home/robert/sites/open-direct-democracy/master/current/app/models/process_document.rb'

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

PROCESS_TYPE_LOG = 1
PROCESS_TYPE_THINGSALYKTUNARTILLAGA = 2

class AlthingiProcessDocumentElement < ProcessDocumentElement
  def parent
    ProcessDocumentElement.find(self.parent_id) if self.parent_id
  end
  
  def content_type_s
    case self.content_type
      when 1 then "TYPE_HEADER_MAIN"
      when 2 then "TYPE_HEADER_CHAPTER"
      when 3 then "TYPE_HEADER_MAIN_ARTICLE"
      when 4 then "TYPE_HEADER_TEMPORARY_ARTICLE"
      when 5 then "TYPE_HEADER_ESSAY"
      when 6 then "TYPE_HEADER_COMMENTS_MAIN"
      when 7 then "TYPE_HEADER_COMMENTS_ABOUT_CHAPTERS"
      when 8 then "TYPE_HEADER_COMMENTS_ABOUT_MAIN_ARTICLES"
      when 9 then "TYPE_HEADER_COMMENTS_ABOUT_TEMPORARY_ARTICLE"
      when 10 then "TYPE_HEADER_COMMENTS_ABOUT_WHOLE_DOCUMENT"
      when 11 then "TYPE_CHAPTER"
      when 12 then "TYPE_MAIN_ARTICLE"
      when 13 then "TYPE_TEMPORARY_ARTICLE"
      when 14 then "TYPE_COMMENTS_ABOUT_CHAPTERS"
      when 15 then "TYPE_COMMENTS_ABOUT_MAIN_ARTICLES"
      when 16 then "TYPE_COMMENTS_ABOUT_TEMPORARY_ARTICLES"
      when 17 then "TYPE_COMMENTS_ABOUT_WHOLE_DOCUMENT"
      when 18 then "TYPE_HEADER_MAIN_CONTENT"
      when 19 then "TYPE_ESSAY_MAIN_CONTENT"
      when 20 then "TYPE_HEADER_REPORT_ABOUT_LAW"
      when 21 then "TYPE_REPORT_ABOUT_LAW"
      else "UNKNOWN"
    end
  end
  
  def set_content_type_for_header    
    if is_main_header?
      self.content_type = TYPE_HEADER_MAIN
    elsif is_main_article_header? or is_thingsalyktinuar_tillaga?
      self.content_type = TYPE_HEADER_MAIN_ARTICLE
    elsif is_temporary_article_header?
     self.content_type = TYPE_HEADER_TEMPORARY_ARTICLE
    elsif is_chapter_header?
      self.content_type = TYPE_HEADER_CHAPTER
    elsif is_essay_header?
      self.content_type = TYPE_HEADER_ESSAY
    elsif is_comments_main_header?
      self.content_type = TYPE_HEADER_COMMENTS_MAIN
    elsif is_comments_about_chapter_header?
      self.content_type = TYPE_HEADER_COMMENTS_ABOUT_CHAPTERS
    elsif is_comments_about_main_article_header?
      self.content_type = TYPE_HEADER_COMMENTS_ABOUT_MAIN_ARTICLES
    elsif is_comments_about_temporary_article_header?
      self.content_type = TYPE_HEADER_COMMENTS_ABOUT_TEMPORARY_ARTICLE
    elsif is_comments_about_whole_process_document_header?
      self.content_type = TYPE_HEADER_COMMENTS_ABOUT_WHOLE_DOCUMENT
    elsif is_report_about_law_header?
      self.content_type = TYPE_HEADER_REPORT_ABOUT_LAW
    else
      puts "Error: Could not find header type for #{self.content}"
    end
  end
      
  def set_content_type_for_main_content
    if parent.content_type == TYPE_HEADER_MAIN_ARTICLE
      self.content_type = TYPE_MAIN_ARTICLE
    elsif parent.content_type == TYPE_HEADER_TEMPORARY_ARTICLE
      self.content_type = TYPE_TEMPORARY_ARTICLE
    elsif parent.content_type == TYPE_HEADER_COMMENTS_ABOUT_CHAPTERS
      self.content_type = TYPE_COMMENTS_ABOUT_CHAPTERS
    elsif parent.content_type == TYPE_HEADER_COMMENTS_ABOUT_MAIN_ARTICLES
      self.content_type = TYPE_COMMENTS_ABOUT_MAIN_ARTICLES
    elsif parent.content_type == TYPE_HEADER_COMMENTS_ABOUT_TEMPORARY_ARTICLE
      self.content_type = TYPE_COMMENTS_ABOUT_TEMPORARY_ARTICLES
    elsif parent.content_type == TYPE_HEADER_COMMENTS_ABOUT_WHOLE_DOCUMENT
      self.content_type = TYPE_COMMENTS_ABOUT_WHOLE_DOCUMENT
    elsif parent.content_type == TYPE_HEADER_MAIN
      self.content_type = TYPE_HEADER_MAIN_CONTENT
    elsif parent.content_type == TYPE_HEADER_ESSAY
      self.content_type = TYPE_ESSAY_MAIN_CONTENT
    elsif parent.content_type == TYPE_HEADER_REPORT_ABOUT_LAW
      self.content_type = TYPE_REPORT_ABOUT_LAW
    else
      puts "Error: Could not find content type for #{self.content} parent: #{parent.inspect}"
    end
  end

  def is_main_header?
    self.sequence_number==1
  end

  def is_chapter_header?
    content.downcase =~ /kafli/
  end
  
  def is_thingsalyktinuar_tillaga?
    content.index("Þingsályktun") or content.index("Tillaga til þingsályktunar")
  end

  def is_main_article_header?
    unless is_comments_about_main_article_header?      
      re1='(\\d+)'  # Integer Number 1
      re2='(\\.)' # Any Single Character 1
      re3='(\\s+)'  # White Space 1
      re4='(gr.)' # Word 1
      
      re=(re1+re2+re3+re4)
      m=Regexp.new(re,Regexp::IGNORECASE);
      if m.match(self.content.gsub(/<!-- Tab -->/," ").gsub(/&nbsp;/," "))
        matched_text_only = m.match(self.content_text_only)
        if matched_text_only and matched_text_only.length>1
          self.content_number=matched_text_only[1];
          return true
        else
          return false
        end
      else
        return false
      end
    else
      return false
    end
  end

  def is_temporary_article_header?
    unless is_comments_about_temporary_article_header?
      compare_to_content_euc("Ákvæði til bráðabirgða.")
    else
      return false
    end
  end

  def is_essay_header?
    compare_to_content_euc("greinargerð")
  end
  
  def is_comments_main_header?
    compare_to_content_euc("Athugasemdir við einstakar greinar frumvarpsins")
 end

  def is_comments_about_chapter_header?
    txt='Um I. kafla.'
    
    re1='(Um)'  # Word 1
    re2='(\\s+)'  # White Space 1
    re3='((?:[a-z][a-z0-9_]*))' # Variable Name 1
    re4='(\\.)' # Any Single Character 1
    re5='(\\s+)'  # White Space 2
    re6='(kafla)' # Word 2
    
    re=(re1+re2+re3+re4+re5+re6)
    m=Regexp.new(re,Regexp::IGNORECASE);
    if m.match(self.content)
        self.content_number=m.match(self.content)[3];  # Store the chapter number
        return true
    end
  end

  def is_comments_about_main_article_header?
    txt='Um 1. gr.'

    re1='(Um)'      # Word 1
    re2='(\\s+)'  # White Space 1
    re3='(\\d+)'  # Integer Number 1
    re4='(\\.)'     # Any Single Character 1
    re5='(\\s+)'  # White Space 2
    re6='(gr)'      # Word 2 end
    
    re=(re1+re2+re3+re4+re5+re6)
    m=Regexp.new(re,Regexp::IGNORECASE);
    if m.match(self.content.downcase.gsub(/&nbsp;/,""))
        self.content_number=m.match(self.content)[3]; # Store the article number
        return true
    else
      return false
    end    
  end

  def is_comments_about_temporary_article_header?
    compare_to_content_euc("Um ákvæði til bráðabirgða")
  end

  def is_comments_about_whole_process_document_header?
    compare_to_content_euc("athugasemdir við lagafrumvarp þetta")
  end
  
  def is_report_about_law_header?
    compare_to_content_euc("umsögn um frumvarp til laga um")
  end
    
  def compare_to_content_euc(string, debug=false)
    input1=string.downcase
    puts "INPUT1: #{input1}" if debug
    input2=self.content.downcase
    puts "INPUT2: #{input2}" if debug
    m=Regexp.new(input1)
    m.match(input2)
  end
end

class ProcessCrawler
end

class AlthingiCrawler < ProcessCrawler

  def strip_chapter_hack(text)
    txt = text.strip.downcase.gsub("\n","").gsub("\r","")
    re1='(<center><b>)'  # Word 1
    re3='((?:[a-z][a-z0-9_]*))' # Variable Name 1
    re4='(\\.)' # Any Single Character 1
    re5='(\\s+)'  # White Space 2
    re6='(kafli)' # Word 2
    
    re=(re1+re3+re4+re5+re6)
    m=Regexp.new(re,Regexp::IGNORECASE);
    if m.match(txt)
      txt[0..txt.index(m.match(txt)[0])-1]
    else
      txt
    end
  end

  def is_article_header?(in_text)
    text = in_text.strip.gsub("\n","").gsub("\r","")
    if ind = text.index("<center>")
      text_front = text[0..ind-1].gsub(" ","")
      if text_front[text_front.length-10..text_front.length-1]=="<aname=\"\">"
        re1='(\\d+)'  # Integer Number 1
        re2='(\\.)' # Any Single Character 1
        re3='(\\s+)'  # White Space 1
        re4='(gr.)' # Word 1
      
        re=(re1+re2+re3+re4)
        m=Regexp.new(re,Regexp::IGNORECASE);
        if m.match(text.gsub(/<!-- Tab -->/," ").gsub(/&nbsp;/," "))
          return true
        else
          return false
        end
      else
        return false
      end
    else
      return false
    end
  end

  def get_thingsalyktun_document(doc, process_id, process_document_id, url)
    puts "GET THYNGSALIKTUNAR DOCUMENT HTML FOR: #{url} process_document: #{process_document_id}"
    html_source_doc = nil
    retries = 10

    begin
      Timeout::timeout(120){
        html_source_doc = Nokogiri::HTML(open(url))
      }
    rescue
      retries -= 1
      if retries > 0
        sleep 0.42 and retry
        puts "retry"
      else
        raise
      end
    end

    if html_source_doc.text.index("Vefskjalið er ekki tilbúið")
      puts "ProcessDocument not yet ready"
      return nil
    end

    if ProcessDocument.find_by_external_link(url)
      puts "Found document at: #{url}"
      return nil
    end
    
    doc.priority_process_id = process_id
    doc.process_document_id = process_document_id
    #doc.category_id = 1
    doc.process_document_state_id = 1
    doc.process_document_type_id = 1
    doc.external_link = url
    doc.voting_close_time = Time.now+1.month
    doc.original_version = true
    doc.save

    elements = []
    sequence_number = 1

    process_document_id = doc.id
    
    div_skip_count = 0
    
    html_source_doc.xpath('//div').each do |paragraph|
      if div_skip_count != 0
        div_skip_count-=1
        puts "DIV SKIP"
        next
      end
      new_parent_header_element = AlthingiProcessDocumentElement.new
      new_parent_header_element.content = paragraph.inspect
      new_parent_header_element.content_text_only = paragraph.text
      new_parent_header_element.sequence_number = sequence_number+=1
      new_parent_header_element.process_document_id = process_document_id
      new_parent_header_element.original_version=true
      new_parent_header_element.set_content_type_for_header
      new_parent_header_element.save
      elements << new_parent_header_element

      next_sibling = paragraph.next_sibling
      all_content_until_next_header = ""
      all_content_until_next_header_text_only = ""
      puts "PROCESSING HEADER TYPE: "+new_parent_header_element.content_type_s
      if new_parent_header_element.content_type == TYPE_HEADER_MAIN_ARTICLE
        puts "Thingsaliktunartillaga main content"
        while next_sibling and not next_sibling.text.index("Greinargerð") and not next_sibling.text.index("Samþykkt á Alþingi")
          puts "SIBLING " + next_sibling.inspect
          if next_sibling.inspect.index("<div ")
            div_skip_count += (next_sibling.inspect.split("<div ").count)-1
            puts "ADDIN DIV SKIP #{div_skip_count}"
          end
          unless next_sibling.inspect[0..3]==" Tab" or
                 next_sibling.inspect[0..8]==" WP Style" or 
                 next_sibling.inspect[0..7]==" WP Pair" or 
                 next_sibling.inspect[0..6]==" Para N" or
                 next_sibling.inspect[0..6]=="<script" or
                 next_sibling.inspect[0..6]=="<noscri" or
                 next_sibling.inspect[0..3]=="<!--"
      
            all_content_until_next_header+= next_sibling.inspect
            all_content_until_next_header_text_only+= next_sibling.text
          end          
          next_sibling = next_sibling.next_sibling
        end
      else
        while next_sibling and next_sibling.inspect[0..3]!="<div" and next_sibling.inspect[0..7]!="<b> <div"
          puts "SIBLING " + next_sibling.inspect
          unless next_sibling.inspect[0..3]==" Tab" or
                 next_sibling.inspect[0..8]==" WP Style" or 
                 next_sibling.inspect[0..7]==" WP Pair" or 
                 next_sibling.inspect[0..6]==" Para N" or
                 next_sibling.inspect[0..6]=="<script" or
                 next_sibling.inspect[0..6]=="<noscri" or
                 next_sibling.inspect[0..3]=="<!--"
      
            all_content_until_next_header+= next_sibling.inspect
            all_content_until_next_header_text_only+= next_sibling.text
          end
          
          next_sibling = next_sibling.next_sibling
        end
      end
      new_main_element = AlthingiProcessDocumentElement.new
      new_main_element.content = all_content_until_next_header
      new_main_element.content_text_only = all_content_until_next_header_text_only
      new_main_element.sequence_number = sequence_number+=1
      new_main_element.parent_id = new_parent_header_element.id
      new_main_element.process_document_id = process_document_id
      new_main_element.set_content_type_for_main_content
      new_main_element.original_version=true
      new_main_element.save
      elements << new_main_element
    end

    for element in elements
      puts "Element sequence number: #{element.sequence_number}"
      puts "Element content type: #{element.content_type_s} - #{element.content_type}"
      puts "Element content number: #{element.content_number}"
      puts "#{element.content_text_only}"
      puts "---------------------------------------------------------------------------------"
    end
    
    puts "HTML"
    
    for element in elements
      puts "#{element.content}"
    end

    return doc
  end
  
  def remove_not_needed_divs(html)
    new_html = ""
    split_html = html.split("\n")
    split_html.each_with_index do |line,i|
      if (line.index("<div style") and line.index("text-align:center") and line.index("</div>") and split_html[i-3].index(". gr.</div>")) and not line.index(". gr.")
        line=line.gsub("div","span")
        puts "DDD: FOUND"
      end
      new_html+=line+"\n"
      puts "DDD:#{line}\n}"
    end
    new_html
  end

  def get_document(doc, process_id, process_document_id, url)
    puts "GET DOCUMENT HTML FOR: #{url} process_document: #{process_document_id}"
    html_source_doc = nil
    retries = 10

    begin
      Timeout::timeout(120){
        html_source_doc = Nokogiri::HTML(remove_not_needed_divs(open(url).read))
      }
    rescue
      retries -= 1
      if retries > 0
        sleep 0.42 and retry
        puts "retry"
      else
        raise
      end
    end

    if html_source_doc.text.index("Vefskjalið er ekki tilbúið")
      puts "ProcessDocument not yet ready"
      return nil
    end

    if ProcessDocument.find_by_external_link(url)
      puts "Found document at: #{url}"
      return nil
    end
    
    doc.priority_process_id = process_id
    doc.process_document_id = process_document_id
    #doc.category_id = 1
    doc.process_document_state_id = 1
    doc.process_document_type_id = 1
    doc.external_link = url
    doc.voting_close_time = Time.now+1.month
    doc.original_version = true
    doc.save

    elements = []
    sequence_number = 0

    process_document_id = doc.id
    
    html_source_doc.xpath('//div').each do |paragraph|
      new_parent_header_element = AlthingiProcessDocumentElement.new
      new_parent_header_element.content = paragraph.inspect
      new_parent_header_element.content_text_only = paragraph.text
      new_parent_header_element.sequence_number = sequence_number+=1
      new_parent_header_element.process_document_id = process_document_id
      new_parent_header_element.original_version=true
      new_parent_header_element.set_content_type_for_header
      new_parent_header_element.save
      elements << new_parent_header_element
      
      next_sibling = paragraph.next_sibling
      all_content_until_next_header = ""
      all_content_until_next_header_text_only = ""
      while next_sibling and next_sibling.inspect[0..3]!="<div" and next_sibling.inspect[0..7]!="<b> <div"
        puts "SIBLING " + next_sibling.inspect
        unless next_sibling.inspect[0..3]==" Tab" or
               next_sibling.inspect[0..8]==" WP Style" or 
               next_sibling.inspect[0..7]==" WP Pair" or 
               next_sibling.inspect[0..6]==" Para N" or
               next_sibling.inspect[0..6]=="<script" or
               next_sibling.inspect[0..6]=="<noscri" or
               next_sibling.inspect[0..3]=="<!--"
    
          all_content_until_next_header+= next_sibling.inspect
          all_content_until_next_header_text_only+= next_sibling.text
        end
        next_sibling = next_sibling.next_sibling

      end
      new_main_element = AlthingiProcessDocumentElement.new
      new_main_element.content = all_content_until_next_header
      new_main_element.content_text_only = all_content_until_next_header_text_only
      new_main_element.sequence_number = sequence_number+=1
      new_main_element.parent_id = new_parent_header_element.id
      new_main_element.process_document_id = process_document_id
      new_main_element.set_content_type_for_main_content
      new_main_element.original_version=true
      new_main_element.save
      elements << new_main_element
    end

    for element in elements
      puts "Element sequence number: #{element.sequence_number}"
      puts "Element content type: #{element.content_type_s} - #{element.content_type}"
      puts "Element content number: #{element.content_number}"
      puts "#{element.content_text_only}"
      puts "---------------------------------------------------------------------------------"
    end
    
    puts "HTML"
    
    for element in elements
      puts "#{element.content}"
    end
    return doc
  end

  # All Icelandic Laws from 1961 http://www.althingi.is/altext/stjtnr.html

  def get_stage_sequence_number(txt, process_type)
    if process_type == PROCESS_TYPE_LOG
      re1='(\\d+)'  # Integer Number 1
      re2='(\\.)' # Any Single Character 1
      re3='(\\s+)'  # White Space 1
      re4='(umræða)' # Word 1
      
      re=(re1+re2+re3+re4)
      m=Regexp.new(re,Regexp::IGNORECASE);
      if m.match(txt)
          int1=m.match(txt)[1];
      end
      
      return int1
    elsif process_type == PROCESS_TYPE_THINGSALYKTUNARTILLAGA
      if txt=="Fyrri umræða"
        return 1
      elsif txt=="Síðari umræða"
        return 2
      end
    end
  end

  def get_process(url, presenter, external_id, external_name, process_type)
   html_doc = nil
   retries = 10
   begin
     Timeout::timeout(120){
       html_doc = Nokogiri::HTML(open(url))
     }
   rescue
     retries -= 1
     if retries > 0
       sleep 0.42 and retry
       puts "retry"
     else
       raise
     end
   end

   ur = URI.parse(url)
   ur_params = CGI.parse(ur.select(:query).to_s)
   ltg = ur_params["ltg"]
   mnr = ur_params["mnr"]

   if process_type == PROCESS_TYPE_LOG
     info_2 = "#{mnr}. mál lagafrumvarp"
   elsif process_type == PROCESS_TYPE_THINGSALYKTUNARTILLAGA
     info_2 = "#{mnr}. mál þingsályktunartillaga" 
   end
   info_3 = "#{ltg}. löggjafarþingi." 

   tags_to_collect = []

   if process_type == PROCESS_TYPE_LOG
     tags_to_collect << "lagafrumvörp"
     unless current_user = User.find_by_email("lagafrumvorp@skuggathing.is")
       current_user=User.new
         current_user.email = "lagafrumvorp@skuggathing.is"
         current_user.login = "Lagafrumvörp frá Alþingi"
       current_user.save(false)
     end
   elsif process_type == PROCESS_TYPE_THINGSALYKTUNARTILLAGA
     tags_to_collect << "þingsályktunartillögur"
     unless current_user = User.find_by_email("thingsalyktunartillaga@skuggathing.is")
       current_user=User.new
       current_user.email = "thingsalyktunartillaga@skuggathing.is"
       current_user.login = "Þingsályktunartillögur frá Alþingi"
       current_user.save(false)
     end
   end

   current_priority = Priority.new
   current_priority.external_info_1 = (html_doc/"h1.FyrirsognStorSv").text.strip
   current_priority.external_info_2 = info_2
   current_priority.external_link = url
   current_priority.external_presenter = presenter
   current_priority.external_id = external_id
   current_priority.external_name = external_name
   current_priority.name = (html_doc/"h1.FyrirsognStorSv").text.strip
   current_priority.user = current_user
   current_priority.ip_address = "127.0.0.1"
   current_priority.issue_list = get_millivis(html_doc,tags_to_collect)

   puts "***************************************** New Process *****************************************"
   puts "Process info 1: "+(html_doc/"h1.FyrirsognStorSv").text.strip
   puts "Process info 2: "+info_2
   puts "Process info 3: "+info_3
   current_priority.external_info_3 = info_3

   old_priority = Priority.find_by_external_link(url)
   if old_priority
     current_priority = old_priority
     puts "OLD PRIORITY "+old_priority.inspect
   else
     current_priority.save
     puts current_priority.inspect
   end

   process_document_sequence_number = 0
   discussion_sequence_number = 0
   stage_sequence_number = 0

   unless process_type = ProcessType.find_by_process_type("Althingi Process")
     process_type = ProcessType.new
     process_type.process_type = "Althingi Process"
     process_type.template_name = "icelandic_parliament"
     process_type.save
   end

   unless process_document_type = ProcessDocumentType.find_by_process_document_type("Althingi Process")
     process_document_type = ProcessDocumentType.new
     process_document_type.process_document_type = "Althingi Process"
     process_document_type.template_name = "icelandic_parliament"
     process_document_type.save
   end
   
   current_process = PriorityProcess.new
   current_process.process_type_id=process_type.id
   current_process.root_node = true
   current_process.parent_id = nil
   current_process.priority_id = current_priority.id
   current_process.process_type = ProcessType.find_by_process_type("Althingi Process")
   current_process.stage_sequence_number=stage_sequence_number+=1

   if (html_doc/"h2.FyrirsognMidSv").text==""
     next_sibling=html_doc.xpath('/html/body/table/tr[2]/td/table/tr/td[2]/div/table')
     puts "============"      
     puts next_sibling.at("tr[1]/td[1]").text
     puts "============"
     #stage_sequence_number = 0
     if next_sibling.at("tr[1]/td[1]").text=="Þingskjöl"
       tr_count = 3
       while next_sibling.at("tr[#{tr_count}]/td[1]")
         process_document = ProcessDocument.new
         process_document.sequence_number=process_document_sequence_number+=1
         process_document.priority_process_id = current_process.id
         process_document.stage_sequence_number = stage_sequence_number
         puts "Date: "+next_sibling.at("tr[#{tr_count}]/td[1]").text.strip
         process_document.external_date = DateTime.strptime(next_sibling.at("tr[#{tr_count}]/td[1]").text.strip, "%d.%m.%Y")
         if next_sibling.at("tr[#{tr_count}]/td[2]/a[@href]")
           puts "ProcessDocument Id: "+next_sibling.at("tr[#{tr_count}]/td[2]/a[@href]").text.strip
           process_document.external_id = next_sibling.at("tr[#{tr_count}]/td[2]/a[@href]").text.strip
           puts "ProcessDocument URL: http://www.althingi.is"+next_sibling.at("tr[#{tr_count}]/td[2]/a[@href]")['href']
           process_document.external_link = "http://www.althingi.is"+next_sibling.at("tr[#{tr_count}]/td[2]/a[@href]")['href']
         end
         if next_sibling.at("tr[#{tr_count}]/td[3]").text
           puts "ProcessDocument Type: "+next_sibling.at("tr[#{tr_count}]/td[3]").text.strip
           process_document.external_type = next_sibling.at("tr[#{tr_count}]/td[3]").text.strip
         else
           puts "ProcessDocument Type: unkown"
         end
         if next_sibling.at("tr[#{tr_count}]/td[4]").text
           puts "ProcessDocument Author: "+next_sibling.at("tr[#{tr_count}]/td[4]").text.strip
           process_document.external_author = next_sibling.at("tr[#{tr_count}]/td[4]").text.strip
         else
           puts "ProcessDocument Author: unkown"
         end
         unless oldpd = ProcessDocument.find_by_external_link(process_document.external_link)
           puts "EXTERNAL_TYPE: " + process_document.external_type
           puts "EXTERNAL_TYPE START3: " + process_document.external_type[0..3]
           if process_document.external_type.index("frumvarp") or process_document.external_type.index("lög")
             document = get_document(process_document, process_document.priority_process_id, process_document.id, process_document.external_link)
           elsif process_document.external_type.downcase.index("þingsályktun") or process_document.external_type.downcase.index("stjórnartillaga")
             document = get_thingsalyktun_document(process_document, process_document.priority_process_id, process_document.id, process_document.external_link)
           end         
           if document
             unless old_process = PriorityProcess.find(:first, :conditions=>["priority_id = ? AND stage_sequence_number = ?",
                                                                             current_process.priority_id, current_process.stage_sequence_number])
               current_process.save
             else
               current_process = old_process
             end
             process_document.priority_process_id = current_process.id
             process_document.process_document_type_id = process_document_type.id
             process_document.save
           end
           puts process_document.inspect
         else
           puts "Found old process document: " + oldpd.inspect
         end
         tr_count+=1
         puts ""
       end
     end
   else
     (html_doc/"h2.FyrirsognMidSv").each do |row|
        # Process stage_sequence
       puts row.text.strip
       #stage_sequence_number = get_stage_sequence_number(row.text.strip, process_type).to_i
       puts "Stage sequence number: #{stage_sequence_number}"
       puts "---------------------"      
       next_sibling = row.next_sibling
       while next_sibling and next_sibling.inspect[0..3]!="<div" and not next_sibling.inspect.include?("FyrirsognMidSv")
         if next_sibling.inspect[0..5]=="<table"
           puts "============"      
           puts next_sibling.at("tr[1]/td[1]").text
           puts "============"
           if next_sibling.at("tr[1]/td[1]").text=="Þingskjöl"
             tr_count = 3
             while next_sibling.at("tr[#{tr_count}]/td[1]")
               process_document = ProcessDocument.new
               process_document.sequence_number=process_document_sequence_number+=1
               process_document.priority_process_id = current_process.id
               process_document.stage_sequence_number = stage_sequence_number
               puts "Date: "+next_sibling.at("tr[#{tr_count}]/td[1]").text.strip
               process_document.external_date = DateTime.strptime(next_sibling.at("tr[#{tr_count}]/td[1]").text.strip, "%d.%m.%Y")
               if next_sibling.at("tr[#{tr_count}]/td[2]/a[@href]")
                 puts "ProcessDocument Id: "+next_sibling.at("tr[#{tr_count}]/td[2]/a[@href]").text.strip
                 process_document.external_id = next_sibling.at("tr[#{tr_count}]/td[2]/a[@href]").text.strip
                 puts "ProcessDocument URL: http://www.althingi.is"+next_sibling.at("tr[#{tr_count}]/td[2]/a[@href]")['href']
                 process_document.external_link = "http://www.althingi.is"+next_sibling.at("tr[#{tr_count}]/td[2]/a[@href]")['href']
               end
               if next_sibling.at("tr[#{tr_count}]/td[3]").text
                 puts "ProcessDocument Type: "+next_sibling.at("tr[#{tr_count}]/td[3]").text.strip
                 process_document.external_type = next_sibling.at("tr[#{tr_count}]/td[3]").text.strip
               else
                 puts "ProcessDocument Type: unkown"
               end
               if next_sibling.at("tr[#{tr_count}]/td[4]").text
                 puts "ProcessDocument Author: "+next_sibling.at("tr[#{tr_count}]/td[4]").text.strip
                 process_document.external_author = next_sibling.at("tr[#{tr_count}]/td[4]").text.strip
               else
                 puts "ProcessDocument Author: unkown"
               end
               unless oldpd = ProcessDocument.find_by_external_link(process_document.external_link)
                 puts "EXTERNAL_TYPE: " + process_document.external_type
                 puts "EXTERNAL_TYPE START3: " + process_document.external_type[0..3]
                 if process_document.external_type.index("frumvarp") or process_document.external_type.index("lög")
                   document = get_document(process_document, process_document.priority_process_id, process_document.id, process_document.external_link)
                 elsif process_document.external_type.downcase.index("þingsályktun") or process_document.external_type.downcase.index("stjórnartillaga")
                   document = get_thingsalyktun_document(process_document, process_document.priority_process_id, process_document.id, process_document.external_link)
                 end         
                 if document
                   unless old_process = PriorityProcess.find(:first, :conditions=>["priority_id = ? AND stage_sequence_number = ?",
                                                                                   current_process.priority_id, current_process.stage_sequence_number])
                     current_process.save
                   else
                     current_process = old_process
                   end
                   process_document.priority_process_id = current_process.id
                   process_document.process_document_type_id = process_document_type.id
                   process_document.save
                 end
                 puts process_document.inspect
               else
                 puts "Found old process document: " + oldpd.inspect
                 if oldpd.stage_sequence_number != stage_sequence_number
                   puts "FIXING DOC STAGE from: #{oldpd.stage_sequence_number} to: #{stage_sequence_number}"
                   oldpd.stage_sequence_number = stage_sequence_number
                   oldpd.save
                 end
               end
               tr_count+=1
               puts ""
             end
           elsif (next_sibling.at("tr[1]/td[1]").inner_html)=="Umræða"
             tr_count = 3
             while next_sibling.at("tr[#{tr_count}]/td[1]")
               process_discussion = ProcessDiscussion.new
               process_discussion.sequence_number=discussion_sequence_number+=1
               process_discussion.priority_process_id = current_process.id
               process_discussion.stage_sequence_number = stage_sequence_number
               if next_sibling.search("tr[#{tr_count}]/td[2]/a[@href]")[0]
                 puts "Discussion Time: "+next_sibling.search("tr[#{tr_count}]/td[2]/a[@href]")[0].text.strip
                 date_from_time = next_sibling.at("tr[#{tr_count}]/td[1]").text.strip + " " + next_sibling.search("tr[#{tr_count}]/td[2]/a[@href]")[0].text.strip[0..4]
                 date_to_time = next_sibling.at("tr[#{tr_count}]/td[1]").text.strip + " " + next_sibling.search("tr[#{tr_count}]/td[2]/a[@href]")[0].text.strip[6..10]
                 process_discussion.from_time = DateTime.strptime(date_from_time, "%d.%m.%Y %H:%M")
                 process_discussion.to_time = DateTime.strptime(date_to_time, "%d.%m.%Y %H:%M")
                 puts "Discussion Time URL: http://www.althingi.is"+next_sibling.search("tr[#{tr_count}]/td[2]/a[@href]")[0]['href']
                 process_discussion.transcript_url="http://www.althingi.is"+next_sibling.search("tr[#{tr_count}]/td[2]/a[@href]")[0]['href']
               end
               if next_sibling.search("tr[#{tr_count}]/td[2]/a[@href]")[1]
                 puts "Listen URL: "+next_sibling.search("tr[#{tr_count}]/td[2]/a[@href]")[1]['href']
                 process_discussion.listen_url=next_sibling.search("tr[#{tr_count}]/td[2]/a[@href]")[1]['href']
               end
               puts "Date: "+next_sibling.at("tr[#{tr_count}]/td[1]").text.strip
               process_discussion.meeting_date = DateTime.strptime(next_sibling.at("tr[#{tr_count}]/td[1]").text.strip, "%d.%m.%Y")
               if next_sibling.at("tr[#{tr_count}]/td[3]").text
                 puts "Meeting Type: "+next_sibling.at("tr[#{tr_count}]/td[3]").text.strip
                 process_discussion.meeting_type = next_sibling.at("tr[#{tr_count}]/td[3]").text.strip
               else
                 puts "Meeting Type: unkown"
               end
               if next_sibling.at("tr[#{tr_count}]/td[4]").text
                 puts "Meeting Info "+next_sibling.at("tr[#{tr_count}]/td[4]").text.strip
                 process_discussion.meeting_info = next_sibling.at("tr[#{tr_count}]/td[4]").text.strip
                 if next_sibling.at("tr[#{tr_count}]/td[4]/a[@href]")
                   puts "Meeting URL: http://www.althingi.is"+next_sibling.at("tr[#{tr_count}]/td[4]/a[@href]")['href']
                   process_discussion.meeting_url = "http://www.althingi.is"+next_sibling.at("tr[#{tr_count}]/td[4]/a[@href]")['href']
                 end
               else
                 puts "Meeting Number: unkown"
               end
               puts ""
               unless oldpd = ProcessDiscussion.find(:first, :conditions => ["listen_url = ? AND transcript_url = ?", 
                                                                    process_discussion.listen_url, process_discussion.transcript_url])
                 unless old_process = PriorityProcess.find(:first, :conditions=>["priority_id = ? AND stage_sequence_number = ?",
                                                                                 current_process.priority_id, current_process.stage_sequence_number])
                   current_process.save
                 else
                   current_process = old_process
                 end
                 process_discussion.priority_process_id = current_process.id
                 process_discussion.save
                 puts process_discussion.inspect
               else
                 puts "Found old process discussion: " + oldpd.inspect
                 if oldpd.stage_sequence_number != stage_sequence_number
                   puts "FIXING DOC STAGE from: #{oldpd.stage_sequence_number} to: #{stage_sequence_number}"
                   oldpd.stage_sequence_number = stage_sequence_number
                   oldpd.save
                 end
               end
               tr_count+=1
             end
           end
           puts "++++++++++++"
         end
         next_sibling = next_sibling.next_sibling
       end
       puts "---------------------"
       old_process = current_process
       current_process = PriorityProcess.new
       current_process.process_type_id=process_type.id
       current_process.root_node = false
       current_process.parent_id = old_process.id
       current_process.priority_id = current_priority.id
       current_process.process_type = ProcessType.find_by_process_type("Althingi Process")
       current_process.stage_sequence_number=stage_sequence_number+=1
     end
   end
 end

 def update_all_processes(process_type)
   if process_type == PROCESS_TYPE_LOG
     html_doc = Nokogiri::HTML(open('http://www.althingi.is/vefur/thingmalalisti.html?cmalteg=l'))
   elsif process_type == PROCESS_TYPE_THINGSALYKTUNARTILLAGA
     html_doc = Nokogiri::HTML(open('http://www.althingi.is/vefur/thingmalalisti.html?cmalteg=afv'))
   end

   next_sibling = html_doc.xpath('/html/body/table/tr[2]/td/table/tr/td/table[2]/tr/td[2]/div/table')
   puts "============"      
   
   tr_count = 2
   while next_sibling.at("tr[#{tr_count}]/td[1]")
     external_process_id = next_sibling.at("tr[#{tr_count}]/td[1]").text.strip
     puts "External Process Id:"+external_process_id
     process_name = ""
     process_name+=next_sibling.at("tr[#{tr_count}]/td[2]").text.strip
     process_url = "http://www.althingi.is"+next_sibling.at("tr[#{tr_count}]/td[2]/a[@href]")['href']
     puts "Process URL: "+process_url
     if next_sibling.at("tr[#{tr_count}]/td[2]/a[@title]") and
        next_sibling.at("tr[#{tr_count}]/td[2]/a[@title]")['title']!=""
       process_name+=" ("+next_sibling.at("tr[#{tr_count}]/td[2]/a[@title]")['title'].strip+")"
     end
     puts "Process name: "+process_name      
     process_author = ""
     process_author+=next_sibling.at("tr[#{tr_count}]/td[3]").text.strip
     if next_sibling.at("tr[#{tr_count}]/td[3]/a[@title]") and 
        next_sibling.at("tr[#{tr_count}]/td[3]/a[@title]")['title']!=""
       process_author+=" ("+next_sibling.at("tr[#{tr_count}]/td[3]/a[@title]")['title'].strip+")"
     end
     puts "Process author: "+process_author
     tr_count+=1
     get_process(process_url, process_author, external_process_id, process_name, process_type)
     sleep 1
     puts ""
   end
  end

  def update_icesave
    get_process("http://www.althingi.is/dba-bin/ferill.pl?ltg=138&mnr=76", "fjármálaráðherra", "stjórnarfrumvarp", 
                "Ríkisábyrgð á lántöku Tryggingarsjóðs innstæðueigenda og fjárfesta (Icesave-reikningar)", PROCESS_TYPE_LOG)
  end
  
  def get_millivis(html_doc,tags_to_collect)
    millivis_addr = html_doc.xpath("/html/body/table/tr[2]/td/table/tr/td[2]/div/p/a[1]")[0]['href']
    html_doc = Nokogiri::HTML(open(URI.encode("http://www.althingi.is#{millivis_addr}")))
    (html_doc/"div.FyrirsognMidSv").each do |top|
       if top.text.index("Efnisorð")
         next_sibling = top.next_sibling
         while (next_sibling.inspect[0..6]=="<a href")
           puts next_sibling.inspect[0..6]
           tags_to_collect << next_sibling.text.gsub(", "," og ")
           next_sibling=next_sibling.next_sibling.next_sibling.next_sibling
         end
       end
     end
     puts tags_to_collect.inspect
     tags_to_collect.join(", ")
  end
end

@current_government = Government.last
if @current_government
  @current_government.update_counts
 Government.current = @current_government
end

acrawler = AlthingiCrawler.new
#acrawler.update_icesave
acrawler.update_all_processes(PROCESS_TYPE_LOG)
acrawler.update_all_processes(PROCESS_TYPE_THINGSALYKTUNARTILLAGA)

#acrawler.get_process("http://www.althingi.is/dba-bin/ferill.pl?ltg=135&mnr=107", "PRESENTER", "ID", "NAME", PROCESS_TYPE_THINGSALYKTUNARTILLAGA)
#acrawler.get_process("http://www.althingi.is/dba-bin/ferill.pl?ltg=135&mnr=62", "PRESENTER", "ID", "NAME", PROCESS_TYPE_THINGSALYKTUNARTILLAGA)
