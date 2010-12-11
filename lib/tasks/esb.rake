require 'rubygems'
require 'nokogiri'
require 'open-uri'

def setup_chapter_tags(treaty_document, chapter_ids)
  unless chapter_ids.empty?
    if chapter_ids[0]==36      
      tags = Tag.all.collect {|tag| "'#{tag.name}'"}.join(",")
      treaty_document.chapter = 36
    elsif chapter_ids[0]==0
      tags = ""
      treaty_document.chapter = 0
    else
      tags = ""
      chapter_ids.each_with_index do |id,i|
        tag = Tag.find_by_external_id(id)
        if tag
          tags += "," unless i==0
          tags += "'#{tag.name}'"
        end
      end
    end
  end
  unless treaty_document.chapter
    if chapter_ids.length==1
      treaty_document.chapter = chapter_ids[0]
    else
      treaty_document.chapter = -1
    end
  end
  treaty_document.issue_list = tags
end

def parse_treaty_doc(element)
  if element.attributes["class"] and element.attributes["class"].value[0..0] == "K"
    puts url = element.attributes["href"].to_s
    puts element.attributes["class"].to_s
    puts title = element.children.to_s
    puts types = element.attributes["class"].value.split(" ")
    treaty_document = TreatyDocument.new
    treaty_document.title = title
    treaty_document.url  = url
    treaty_document.document_type  = 1
    types.each do |type|
      if type[0..0]=="K"
        setup_chapter_tags(treaty_document, type[1..type.length].split("_").collect {|id| id.to_i})
      elsif type[0..0]=="T"
        treaty_document.document_content_type = type[1..type.length].to_i
      elsif type[0..0]=="S"
        treaty_document.negotiation_status = type[1..type.length].to_i
      elsif type[0..0]=="F"
        treaty_document.category = type[1..type.length]
      elsif type[0..0]=="D"
        treaty_document.date = DateTime.parse("#{type[1..6]}20#{type[7..8]}".gsub("_","."))
      end
    end
    treaty_document.save
    treaty_document.inspect
  end  
end
 
namespace :esb do
  desc "Crawl treaty documents"
  task(:crawl_treaty_documents => :environment) do
    ActiveRecord::Base.transaction do
      TreatyDocument.destroy_all
      subs = []
      (5775..5810).each do |n|
        next if n==5789
        subs<<"http://esb.utn.is/hlidarval/malaflokkar-vidraedna/kaflar/nr/#{n}" 
      end
      (subs+["http://esb.utn.is/hlidarval/skjol-og-tenglar/skjol-fra-esb/",
       "http://esb.utn.is/hlidarval/skjol-og-tenglar/skjol-fra-isl/",
       "http://esb.utn.is/hlidarval/skjol-og-tenglar/onnur-skjol/",
       "http://esb.utn.is/hlidarval/frettir/",
       "http://esb.utn.is/samninganefnd-islands-og-samningahopar/samningahopar/fundarfrasagnir/nr/5846",
       "http://esb.utn.is/samninganefnd-islands-og-samningahopar/samningahopar/fundarfrasagnir/nr/5835",
       "http://esb.utn.is/samninganefnd-islands-og-samningahopar/samningahopar/fundarfrasagnir/nr/5847",
       "http://esb.utn.is/samninganefnd-islands-og-samningahopar/samningahopar/fundarfrasagnir/nr/5848",
       "http://esb.utn.is/samninganefnd-islands-og-samningahopar/samningahopar/fundarfrasagnir/nr/5849",
       "http://esb.utn.is/samninganefnd-islands-og-samningahopar/samningahopar/fundarfrasagnir/nr/5850",
       "http://esb.utn.is/samninganefnd-islands-og-samningahopar/samningahopar/fundarfrasagnir/nr/5851",
       "http://esb.utn.is/samninganefnd-islands-og-samningahopar/samningahopar/fundarfrasagnir/nr/5852",
       "http://esb.utn.is/samninganefnd-islands-og-samningahopar/samningahopar/fundarfrasagnir/nr/5853",
       "http://esb.utn.is/samninganefnd-islands-og-samningahopar/samningahopar/fundarfrasagnir/nr/5854"]).each do |url_to_parse|
      puts "Crawling #{url_to_parse}"
      html_doc = Nokogiri::HTML(open(url_to_parse))
      main_div = html_doc.at("div.boxbody")
        main_div.children.search("a").each do |element|
           parse_treaty_doc(element)
        end
      end
    end
  end

  desc "Create esb tags"
  task(:create_tags => :environment) do
      Tag.destroy_all
      TagSubscription.delete_all
      [["Félagaréttur",6],
      ["Fjármálaþjónusta",9],
      ["Frjáls för fjármagns",4],
      ["Frjáls för vinnuafls",2],
       ["Frjálst vöruflæði",1],
       ["Hugverkaréttur",7],
       ["Opinber útboð",5],
       ["Samkeppnismál",8],
       ["Staðfesturéttur og þjónustufrelsi",3],
       ["Upplýsingatækni og fjölmiðlun",10]].each_with_index do |t,i|
        tag=Tag.new
        tag.name = t[0]
        tag.weight = i
        tag.tag_type = 1
        tag.external_id = t[1]
        tag.save
      end
      [["Evrópsk samgöngunet",21],
      ["Félagsmála- og atvinnustefna",19],
      ["Hagtölur",18],
      ["Iðnstefna",20],
      ["Matvæla- og hreinlætismál",12],
      ["Menntun og menning",26],
      ["Neytenda- og heilsuvernd",28],
      ["Orka",15],
      ["Samgöngur",14],
      ["Umhverfismál",27],
      ["Vísindi og rannsóknir",25]].each_with_index do |t,i|
        tag=Tag.new
        tag.name = t[0]
        tag.weight = i
        tag.tag_type = 2
        tag.external_id = t[1]
        tag.save
      end
      [["Dóms- og innanríkismál",24],
      ["Fjárhagslegt eftirlit",32],
      ["Framlagsmál",33],
      ["Gjaldmiðilssamstarf",17],
      ["Landbúnaður og byggðastefna",11],
      ["Réttarvarsla og grundvallarréttindi",23],
      ["Sjávarútvegsmál",13],
      ["Skattamál",16],
      ["Tollabandalag",29],
      ["Uppbyggingarstyrkir",22],
      ["Utanríkis-, öryggis- og varnarmál",31],
      ["Utanríkistengsl",30]].each_with_index do |t,i|
        tag=Tag.new
        tag.name = t[0]
        tag.weight = i
        tag.tag_type = 3
        tag.external_id = t[1]
        tag.save
      end
      [["Stofnanir",34],
      ["Annað",35]].each_with_index do |t,i|
        tag=Tag.new
        tag.name = t[0]
        tag.weight = i
        tag.tag_type = 4
        tag.external_id = t[1]
        tag.save
      end
  end

  desc "Send reports"
  task(:send_reports=> :environment) do
    User.find_all_by_reports_enabled(1).each do |user|
      user.send_report_if_needed!
    end
  end

  desc "Create dummy treaty test data"
  task(:treaty_test_data => :environment) do
    TreatyDocument.destroy_all

    t=TreatyDocument.new
    t.chapter = 1
    t.document_content_type = 1
    t.negotiation_status = 1
    t.document_type = 1
    t.title = "Skýrsla um aukið samstarf Norðurlandanna og Eystrasaltsríkjanna (á ensku)"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save
    
    t=TreatyDocument.new
    t.chapter = 1
    t.document_content_type = 1
    t.negotiation_status = 1
    t.document_type = 1
    t.title = "önnur skýrsla í fyrsta kafla og á fyrsta stigi"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save
 
    t=TreatyDocument.new
    t.chapter = 1
    t.document_content_type = 1
    t.negotiation_status = 1
    t.document_type = 1
    t.title = "önnur skýrsla í fyrsta kafla og á fyrsta stigi"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save
    
    t=TreatyDocument.new
    t.chapter = 1
    t.document_content_type = 1
    t.negotiation_status = 1
    t.document_type = 1
    t.title = "önnur skýrsla í fyrsta kafla og á fyrsta stigi"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save
    
    t=TreatyDocument.new
    t.chapter = 1
    t.document_content_type = 1
    t.negotiation_status = 1
    t.document_type = 1
    t.title = "önnur skýrsla í fyrsta kafla og á fyrsta stigi"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save
    
    t=TreatyDocument.new
    t.chapter = 1
    t.document_content_type = 1
    t.negotiation_status = 1
    t.document_type = 1
    t.title = "önnur skýrsla í fyrsta kafla og á fyrsta stigi"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save
    
    t=TreatyDocument.new
    t.chapter = 1
    t.document_content_type = 1
    t.negotiation_status = 1
    t.document_type = 1
    t.title = "önnur skýrsla í fyrsta kafla og á fyrsta stigi"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save
    
    t=TreatyDocument.new
    t.chapter = 1
    t.document_content_type = 1
    t.negotiation_status = 1
    t.document_type = 1
    t.title = "önnur skýrsla í fyrsta kafla og á fyrsta stigi"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save
    
    t=TreatyDocument.new
    t.chapter = 1
    t.document_content_type = 1
    t.negotiation_status = 1
    t.document_type = 1
    t.title = "önnur skýrsla í fyrsta kafla og á fyrsta stigi"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save
    
    t=TreatyDocument.new
    t.chapter = 1
    t.document_content_type = 1
    t.negotiation_status = 1
    t.document_type = 1
    t.title = "önnur skýrsla í fyrsta kafla og á fyrsta stigi"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save
    
    t=TreatyDocument.new
    t.chapter = 1
    t.document_content_type = 1
    t.negotiation_status = 1
    t.document_type = 1
    t.title = "önnur skýrsla í fyrsta kafla og á fyrsta stigi"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save
    
    t=TreatyDocument.new
    t.chapter = 2
    t.document_content_type = 2
    t.negotiation_status = 2
    t.document_type = 2
    t.title = "Skýrsla 2 um aukið samstarf Norðurlandanna og Eystrasaltsríkjanna (á ensku)"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save

    t=TreatyDocument.new
    t.chapter = 2
    t.document_content_type = 2
    t.negotiation_status = 2
    t.document_type = 2
    t.title = "Skýrsla 2 um aukið samstarf Norðurlandanna og Eystrasaltsríkjanna (á ensku)"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save

    t=TreatyDocument.new
    t.chapter = 2
    t.document_content_type = 2
    t.negotiation_status = 2
    t.document_type = 2
    t.title = "Skýrsla 2 um aukið samstarf Norðurlandanna og Eystrasaltsríkjanna (á ensku)"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save

    t=TreatyDocument.new
    t.chapter = 2
    t.document_content_type = 2
    t.negotiation_status = 2
    t.document_type = 2
    t.title = "Skýrsla 2 um aukið samstarf Norðurlandanna og Eystrasaltsríkjanna (á ensku)"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save


    
    t=TreatyDocument.new
    t.chapter = 3
    t.document_content_type = 3
    t.negotiation_status = 3
    t.document_type = 3
    t.title = "Skýrsla 3 um aukið samstarf Norðurlandanna og Eystrasaltsríkjanna (á ensku)"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save
    
     t=TreatyDocument.new
    t.chapter = 7
    t.document_content_type = 3
    t.negotiation_status = 3
    t.document_type = 3
    t.title = "Skýrsla 3 um aukið samstarf Norðurlandanna og Eystrasaltsríkjanna (á ensku)"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save
    
    t=TreatyDocument.new
    t.chapter = 7
    t.document_content_type = 3
    t.negotiation_status = 3
    t.document_type = 3
    t.title = "Skýrsla 3 um aukið samstarf Norðurlandanna og Eystrasaltsríkjanna (á ensku)"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save
    
    t=TreatyDocument.new
    t.chapter = 7
    t.document_content_type = 3
    t.negotiation_status = 3
    t.document_type = 3
    t.title = "Skýrsla 3 um aukið samstarf Norðurlandanna og Eystrasaltsríkjanna (á ensku)"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save
    
    t=TreatyDocument.new
    t.chapter = 7
    t.document_content_type = 3
    t.negotiation_status = 3
    t.document_type = 3
    t.title = "Skýrsla 3 um aukið samstarf Norðurlandanna og Eystrasaltsríkjanna (á ensku)"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save
    
    t=TreatyDocument.new
    t.chapter = 7
    t.document_content_type = 3
    t.negotiation_status = 3
    t.document_type = 3
    t.title = "Skýrsla 3 um aukið samstarf Norðurlandanna og Eystrasaltsríkjanna (á ensku)"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save
    
    t=TreatyDocument.new
    t.chapter = 7
    t.document_content_type = 3
    t.negotiation_status = 3
    t.document_type = 3
    t.title = "Skýrsla 3 um aukið samstarf Norðurlandanna og Eystrasaltsríkjanna (á ensku)"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save
    
    t=TreatyDocument.new
    t.chapter = 7
    t.document_content_type = 3
    t.negotiation_status = 3
    t.document_type = 3
    t.title = "Skýrsla 3 um aukið samstarf Norðurlandanna og Eystrasaltsríkjanna (á ensku)"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save
    
    t=TreatyDocument.new
    t.chapter = 7
    t.document_content_type = 3
    t.negotiation_status = 3
    t.document_type = 3
    t.title = "Skýrsla 3 um aukið samstarf Norðurlandanna og Eystrasaltsríkjanna (á ensku)"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save
    
    t=TreatyDocument.new
    t.chapter = 7
    t.document_content_type = 3
    t.negotiation_status = 3
    t.document_type = 3
    t.title = "Skýrsla 3 um aukið samstarf Norðurlandanna og Eystrasaltsríkjanna (á ensku)"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save
    
    t=TreatyDocument.new
    t.chapter = 8
    t.document_content_type = 3
    t.negotiation_status = 3
    t.document_type = 3
    t.title = "Skýrsla 3 um aukið samstarf Norðurlandanna og Eystrasaltsríkjanna (á ensku)"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save
    
    t=TreatyDocument.new
    t.chapter = 8
    t.document_content_type = 3
    t.negotiation_status = 3
    t.document_type = 3
    t.title = "Skýrsla 3 um aukið samstarf Norðurlandanna og Eystrasaltsríkjanna (á ensku)"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save
    
    t=TreatyDocument.new
    t.chapter = 8
    t.document_content_type = 3
    t.negotiation_status = 3
    t.document_type = 3
    t.title = "Skýrsla 3 um aukið samstarf Norðurlandanna og Eystrasaltsríkjanna (á ensku)"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save
    
    t=TreatyDocument.new
    t.chapter = 8
    t.document_content_type = 3
    t.negotiation_status = 3
    t.document_type = 3
    t.title = "Skýrsla 3 um aukið samstarf Norðurlandanna og Eystrasaltsríkjanna (á ensku)"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save
    
     t=TreatyDocument.new
    t.chapter = 8
    t.document_content_type = 3
    t.negotiation_status = 3
    t.document_type = 3
    t.title = "Skýrsla 3 um aukið samstarf Norðurlandanna og Eystrasaltsríkjanna (á ensku)"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save
    
     t=TreatyDocument.new
    t.chapter = 8
    t.document_content_type = 3
    t.negotiation_status = 3
    t.document_type = 3
    t.title = "Skýrsla 3 um aukið samstarf Norðurlandanna og Eystrasaltsríkjanna (á ensku)"
    t.url = "http://www.utanrikisraduneyti.is/media/Skyrslur/NB8-Wise-Men-Report.pdf"
    t.save
    
  end
end
