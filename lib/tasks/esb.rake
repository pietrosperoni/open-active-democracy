require 'rubygems'
require 'nokogiri'
require 'open-uri'
 
namespace :esb do
  desc "Crawl treaty documents"
  task(:crawl_treaty_documents => :environment) do
    html_doc = Nokogiri::HTML(open('http://eu.mfa.is/test/skrap'))
    main_div = html_doc.at("div.boxbody")
    ActiveRecord::Base.transaction do
      TreatyDocument.destroy_all
      main_div.children.search("a").each do |element|
        if element.attributes["class"] and element.attributes["class"].value[0..0] == "K"
          puts url = element.attributes["href"].to_s
          puts element.attributes["class"].to_s
          puts title = element.children.to_s
          types = element.attributes["class"].value.split(" ")
          puts types
          puts chapter_id = types[0][1..types[0].length]
          puts content_type_id = types[1][1..types[1].length]
          puts status_id = types[2][1..types[2].length]
          t=TreatyDocument.new
          t.chapter = chapter_id.to_i
          t.document_content_type = content_type_id.to_i
          t.negotiation_status = status_id.to_i
          t.title = title
          t.document_type = 3
          t.url = url
          t.save
        end
      end
    end
  end

  desc "Create esb tags"
  task(:create_tags => :environment) do
      Tag.destroy_all
      [["Félagaréttur",6],
      ["Fjármálaþjónusta",9],
      ["Frjáls för fjármagns",4],
      ["Frjáls för vinnuafls",2],
       ["Frjálst vöruflæði",1],
       ["Hugverkaréttur",7],
       ["Opinber útboð",5],
       ["Samkeppnismál",8],
       ["Staðfesturéttur og þjónustufrelsi",3],
       ["Upplýsingatækni og fjölmiðlum",10]].each_with_index do |t,i|
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
      ["Fiskveiðar",13],
      ["Fjárhagslegt eftirlit",32],
      ["Framlagsmál",33],
      ["Gjaldmiðilssamstarf",17],
      ["Landbúnaður og byggðastefna",11],
      ["Réttarvarsla og grundvallarréttindi",23],
      ["Skattamál",16],
      ["Tollabandalag",29],
      ["Uppbyggingarstyrkir",22],
      ["Utanríkis-, öryggis- og varnamál",31],
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
