namespace :esb do
  desc "Create esb tags"
  task(:create_tags => :environment) do
      Tag.destroy_all
      ["Félagaréttur","Fjármálaþjónusta","Frjáls för fjármagns",
       "Frjáls för vinnuafls","Frjálst vöruflæði","Hugverkaréttur",
       "Opinber útboð","Samkeppnismál","Staðfesturéttur og þjónustufrelsi",
       "Upplýsingatækni og fjölmiðlum"].each_with_index do |t,i|
        tag=Tag.new
        tag.name = t
        tag.weight = i
        tag.tag_type = 1
        tag.save
      end
      ["Evrópsk samgöngunet","Félagsmála- og atvinnustefna","Hagtölur",
      "Iðnstefna","Matvæla- og hreinlætismál","Menntun og menning","Neytenda- og heilsuvernd",
      "Orka","Samgöngur","Umhverfismál","Vísindi og rannsóknir"].each_with_index do |t,i|
        tag=Tag.new
        tag.name = t
        tag.weight = i
        tag.tag_type = 2
        tag.save
      end
      ["Dóms- og innanríkismál","Fiskveiðar","Fjárhagslegt eftirlit",
      "Framlagsmál","Gjaldmiðilssamstarf","Landbúnaður og byggðastefna","Réttarvarsla og grundvallarréttindi",
      "Skattamál","Tollabandalag","Uppbyggingarstyrkir","Utanríkis-, öryggis- og varnamál",
      "Utanríkistengsl"].each_with_index do |t,i|
        tag=Tag.new
        tag.name = t
        tag.weight = i
        tag.tag_type = 3
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
  end
end
