# coding: utf-8
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

require './crawler_utils'
require 'htmlentities'

class LawProposalDocumentElement < ProcessDocumentElement

  @@decoder = HTMLEntities.new

  def self.remove_not_needed_divs!(html)
    new_html = ""
    if html.length<1560916
      begin
        split_html = html.split("\n")
        split_html.each_with_index do |line,i|
          if (line.index("<div style") and line.index("text-align:center") and line.index("</div>") and split_html[i-3].index(". gr.</div>")) and not line.index(". gr.")
            line=line.gsub("div","span")
          end
          new_html+=line+"\n"
        end
      rescue Timeout::Error
        new_html=html
      rescue
        new_html=html
      end
    else
      puts "Skipping to long html doc..."
      new_html=html
    end
    html = new_html
  end
  
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
      puts "Error: Couldn't find header type for: #{self.content.to_s[0..50].inspect}"
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
      puts "Error: Couldn't find content type for: #{self.content.to_s[0..50].inspect}"
    end
  end

  def is_main_header?
    self.sequence_number==1
  end

  def is_chapter_header?
    content_text_only =~ /kafli/
  end
  
  def is_thingsalyktinuar_tillaga?
    content_text_only =~ /þingsályktun/i or content_text_only =~ /Tillaga til þingsályktunar/i
  end

  def is_main_article_header?
    unless is_comments_about_main_article_header?
      if numeral = LawProposalDocumentElement.has_roman_numeral(self.content)
        self.content_number = LawProposalDocumentElement.roman_to_arabic(numeral)
        return true
      end

      re1='(\\d+)'  # Integer Number 1
      re2='(\\.)' # Any Single Character 1
      re3='(\\s+)'  # White Space 1
      re4='(gr.)' # Word 1
      
      re=(re1+re2+re3+re4)
      m=Regexp.new(re,Regexp::IGNORECASE);
      if m.match(self.content_text_only)
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

  def self.has_roman_numeral(input)
    re1 = "<b>\s*"
    re2 = '(M{0,4}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3}))' # roman numeral
    re3 = '(\\.)'
    re = (re1+re2+re3)
    m=Regexp.new(re,Regexp::IGNORECASE);
    if m.match(input)
      matched = m.match(input)
      if matched and matched.length>1
        return matched[1];
      end
    end
    return nil
  end

  def self.roman_to_arabic(roman)
    roman_to_arabic = {
        'I' => 1,
        'V' => 5,
        'X' => 10,
        'L' => 50,
        'C' => 100,
        'D' => 500,
        'M' => 1000,
    }

    roman_digit = {
        1    => 'IV',
        10   => 'XL',
        100  => 'CD',
        1000 => 'MMMMMM',
    }

    figure = roman_digit.keys.sort.reverse
    figure.each { |f| roman_digit[f] = roman_digit[f].split(//, 2) }

    last_digit = 1000
    arabic = 0
    roman.upcase.split(//).each do |char|
      digit = roman_to_arabic[char]
      arabic -= 2 * last_digit if last_digit < digit
      last_digit = digit
      arabic += last_digit
    end
    return arabic
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
    if m.match(self.content_text_only)
        self.content_number=m.match(self.content_text_only)[3];  # Store the chapter number
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
    if m.match(self.content_text_only)
        self.content_number=m.match(self.content_text_only)[3]; # Store the article number
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
    input1=string
    puts "INPUT1: #{input1}" if debug
    input2=self.content_text_only
    puts "INPUT2: #{input2}" if debug
    m=Regexp.new(input1, Regexp::IGNORECASE)
    m.match(input2)
  end

  def self.skip_tokens(next_sibling)
    next_sibling.to_s[0..3]==" Tab" or
    next_sibling.to_s[0..8]==" WP Style" or
    next_sibling.to_s[0..7]==" WP Pair" or
    next_sibling.to_s[0..6]==" Para N" or
    next_sibling.to_s[0..6]=="<script" or
    next_sibling.to_s[0..6]=="<noscri" or
    next_sibling.to_s[0..3]=="<!--"
  end

  def self.create_elements(doc, process_id, process_document_id, url, process_type)
    html_source_doc = CrawlerUtils.fetch_html(url) do |source|
      remove_not_needed_divs!(source)
    end

    if html_source_doc.text.index("Vefskjalið er ekki tilbúið")
      puts "ProcessDocument not yet ready"
      return nil
    end

    if ProcessDocument.find_by_external_link(url)
      puts "Found ProcessDocument at: #{url}"
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
    sequence_number = process_type == PROCESS_TYPE_THINGSALYKTUNARTILLAGA ? 1 : 0

    process_document_id = doc.id
    div_skip_count = 0

    html_source_doc.xpath('//div').each do |paragraph|
      if div_skip_count != 0 # and process_type == PROCESS_TYPE_THINGSALYKTUNARTILLAGA
        div_skip_count-=1
        next
      end

      new_parent_header_element = LawProposalDocumentElement.new
      new_parent_header_element.content = @@decoder.decode(paragraph.to_s)
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

      if new_parent_header_element.content_type == TYPE_HEADER_MAIN_ARTICLE and process_type == PROCESS_TYPE_THINGSALYKTUNARTILLAGA
        while next_sibling and not next_sibling.text.index("Greinargerð") and not next_sibling.text.index("Samþykkt á Alþingi") and not
               next_sibling.text.index("Athugasemdir við þingsályktunartillögu þessa.") and not LawProposalDocumentElement.has_roman_numeral(next_sibling.to_s)
          if next_sibling.to_s.index("<div ")
            div_skip_count += (next_sibling.to_s.split("<div ").count)-1
          end
          unless skip_tokens(next_sibling)
            all_content_until_next_header+= @@decoder.decode(next_sibling.to_s)
            all_content_until_next_header_text_only+= next_sibling.text
          end          
          next_sibling = next_sibling.next_sibling
        end
      else
        while next_sibling and not next_sibling.text.index("Athugasemdir við lagafrumvarp þetta.")
          if next_sibling.to_s =~ /\A\s*<div[^>]+?>\s*<i>/
            div_skip_count += (next_sibling.to_s.split("<div ").count)-1
          end
          if next_sibling and (next_sibling.to_s[0..7]=="<b> <div" or next_sibling.to_s =~ /\A\s*<div[^>]+?>\s*[^<\s]/)
            break
          end
          first = false
          unless skip_tokens(next_sibling)
            all_content_until_next_header+= @@decoder.decode(next_sibling.to_s)
            all_content_until_next_header_text_only+= next_sibling.text
          end          
          next_sibling = next_sibling.next_sibling
        end
      end
      new_main_element = LawProposalDocumentElement.new
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

    return doc
  end  
end