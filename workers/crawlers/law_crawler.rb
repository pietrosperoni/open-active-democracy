# coding: utf-8
# Copyright (C) 2008, 2009, 2010, 2011 Róbert Viðar Bjarnason
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

#TODO:
# Fix when document has "uppprentun" in the type name - this causes an extra copy of the whole proposal to be added as one element at the beginning
# e.g. http://www.althingi.is/altext/138/s/0003.html
# 
# Implement law_document_element.rb for parsing actual passed laws, currently law_proposal_document_element.rb only covers law proposals not the final 
# version of the document that is in a completly different html format.

require 'rubygems'
require 'nokogiri'
require 'tidy'
require 'open-uri'
require 'timeout'

require '../../config/boot'
require "../../config/environment"

require './law_proposal_document_element'
require './process_parser'
require './tags_parser'

PROCESS_TYPE_LOG = 1
PROCESS_TYPE_THINGSALYKTUNARTILLAGA = 2
PARLIAMENTARY_SESSIONS = ARGV

class ProcessCrawler
end

class AlthingiCrawler < ProcessCrawler

 def update_all_processes(process_type, session=nil)
   session_tag = session ? "&validthing=#{session}" : ""
   if process_type == PROCESS_TYPE_LOG
     buffer = open("http://www.althingi.is/vefur/thingmalalisti.html?cmalteg=l#{session_tag}").read
   elsif process_type == PROCESS_TYPE_THINGSALYKTUNARTILLAGA
     buffer = open("http://www.althingi.is/vefur/thingmalalisti.html?cmalteg=afv#{session_tag}").read
   end

   Tidy.open({ "char-encoding" => "utf8", "wrap" => 0 }) do |tidy|
     buffer = tidy.clean(buffer)
   end
   html_doc = Nokogiri::HTML(buffer)

   next_sibling = html_doc.xpath('/html/body/table/tr[2]/td/table/tr/td/table[2]/tr/td[2]/div/table')
   puts "============"

   tr_count = 2
   while next_sibling.at("tr[#{tr_count}]/td[1]")
     external_process_id = next_sibling.at("tr[#{tr_count}]/td[1]").text.strip
     puts "Found process with external id "+external_process_id
     process_name = ""
     process_name+=next_sibling.at("tr[#{tr_count}]/td[3]").text.strip
     process_url = "http://www.althingi.is"+next_sibling.at("tr[#{tr_count}]/td[3]/a[@href]")['href']
     puts "Process url: "+process_url
     if next_sibling.at("tr[#{tr_count}]/td[3]/a[@title]") and
        next_sibling.at("tr[#{tr_count}]/td[3]/a[@title]")['title']!=""
       process_name+=" ("+next_sibling.at("tr[#{tr_count}]/td[3]/a[@title]")['title'].strip+")"
     end
     puts "Process name: "+process_name      
     process_author = ""
     process_author+=next_sibling.at("tr[#{tr_count}]/td[4]").text.strip
     if next_sibling.at("tr[#{tr_count}]/td[4]/a[@title]") and
        next_sibling.at("tr[#{tr_count}]/td[4]/a[@title]")['title']!=""
       process_author+=" ("+next_sibling.at("tr[#{tr_count}]/td[4]/a[@title]")['title'].strip+")"
     end
     puts "Process author: "+process_author
     tr_count+=1

     ProcessParser.get_process(process_url, process_author, external_process_id, process_name, process_type)
     sleep 1
     puts ""
   end
  end

  def update_icesave
    ProcessParser.get_process("http://www.althingi.is/dba-bin/ferill.pl?ltg=138&mnr=76", "fjármálaráðherra", "stjórnarfrumvarp", 
                "Ríkisábyrgð á lántöku Tryggingarsjóðs innstæðueigenda og fjárfesta (Icesave-reikningar)", PROCESS_TYPE_LOG)
  end  

  def update_icesave1
    ProcessParser.get_process("http://www.althingi.is/dba-bin/ferill.pl?ltg=137&mnr=136", "fjármálaráðherra", "stjórnarfrumvarp", 
                "Ríkisábyrgð á lántöku Tryggingarsjóðs innstæðueigenda og fjárfesta (Icesave-samningar)", PROCESS_TYPE_LOG)
  end  

end

@current_government = Government.last
if @current_government
  @current_government.update_counts
  Government.current = @current_government
end

acrawler = AlthingiCrawler.new
#acrawler.update_icesave

if PARLIAMENTARY_SESSIONS.empty?
  puts "PROCESSING LATEST PARLIAMENTARY SESSION ONLY"
  acrawler.update_all_processes(PROCESS_TYPE_LOG)
  acrawler.update_all_processes(PROCESS_TYPE_THINGSALYKTUNARTILLAGA)
else
  PARLIAMENTARY_SESSIONS.each do |session|
    puts "PROCESSING PARLIAMENTARY SESSION #{session}"
    acrawler.update_all_processes(PROCESS_TYPE_LOG, session)
    acrawler.update_all_processes(PROCESS_TYPE_THINGSALYKTUNARTILLAGA, session)
  end
end

#acrawler.get_process("http://www.althingi.is/dba-bin/ferill.pl?ltg=135&mnr=107", "PRESENTER", "ID", "NAME", PROCESS_TYPE_THINGSALYKTUNARTILLAGA)
#acrawler.get_process("http://www.althingi.is/dba-bin/ferill.pl?ltg=135&mnr=62", "PRESENTER", "ID", "NAME", PROCESS_TYPE_THINGSALYKTUNARTILLAGA)

  # All Icelandic Laws from 1961 http://www.althingi.is/altext/stjtnr.html
