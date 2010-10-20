class TreatyDocument < ActiveRecord::Base

  MAXIMUM_NUMBER_OF_DOCUMENTS = 15

  NEGOTIATION_STAGES = [
                     {:id=>1, :name=>"Umsóknarferli"},
                     {:id=>2, :name=>"Rikjaradstefna"},
                     {:id=>3, :name=>"Rýnivinna"},
                     {:id=>4, :name=>"Viðmið fyrir opnun kafla"},
                     {:id=>5, :name=>"Samningsafstaða Íslands"},
                     {:id=>6, :name=>"Samningsafstaða ESB"},
                     {:id=>7, :name=>"Opnun kafla"},
                     {:id=>8, :name=>"Viðmð fyrir lokun kafla"},
                     {:id=>9, :name=>"Aðildarsamningur"}
          ]
  TREATY_ARRAY = [
               {:id=>1, :name=>"Frjálst vöruflæði", :negotiation_stages=>NEGOTIATION_STAGES},
               {:id=>2, :name=>"Frjáls för vinnuafls", :negotiation_stages=>NEGOTIATION_STAGES},
               {:id=>3, :name=>"Staðfesturéttur og þjónustufrelsi", :negotiation_stages=>NEGOTIATION_STAGES},
               {:id=>4, :name=>"Frjáls för fjármagns", :negotiation_stages=>NEGOTIATION_STAGES},
               {:id=>5, :name=>"Opinber útboð", :negotiation_stages=>NEGOTIATION_STAGES},
               {:id=>6, :name=>"Félagaréttur", :negotiation_stages=>NEGOTIATION_STAGES},
               {:id=>7, :name=>"Hugverkaréttur", :negotiation_stages=>NEGOTIATION_STAGES},
               {:id=>8, :name=>"Samkeppnismál", :negotiation_stages=>NEGOTIATION_STAGES},
               {:id=>9, :name=>"Fjármálaþjónusta", :negotiation_stages=>NEGOTIATION_STAGES},
               {:id=>10, :name=>"Upplýsingatækni og fjölmiðlun", :negotiation_stages=>NEGOTIATION_STAGES},
               {:id=>11, :name=>"Landbúnaðar- og byggðastefna", :negotiation_stages=>NEGOTIATION_STAGES},                        
               {:id=>12, :name=>"Matvæla- og hreinlætismál", :negotiation_stages=>NEGOTIATION_STAGES},                         
               {:id=>13, :name=>"Fiskveiðar", :negotiation_stages=>NEGOTIATION_STAGES},                        
               {:id=>14, :name=>"Samgöngur", :negotiation_stages=>NEGOTIATION_STAGES},                         
               {:id=>15, :name=>"Orka", :negotiation_stages=>NEGOTIATION_STAGES},                        
               {:id=>16, :name=>"Skattamál", :negotiation_stages=>NEGOTIATION_STAGES},                         
               {:id=>17, :name=>"Gjaldmiðilssamstarf", :negotiation_stages=>NEGOTIATION_STAGES},                         
               {:id=>18, :name=>"Hagtölur", :negotiation_stages=>NEGOTIATION_STAGES},                        
               {:id=>19, :name=>"Félagsmála- og atvinnustefna", :negotiation_stages=>NEGOTIATION_STAGES},                        
               {:id=>20, :name=>"Iðnstefna", :negotiation_stages=>NEGOTIATION_STAGES},                         
               {:id=>21, :name=>"Evrópsk samgöngunet", :negotiation_stages=>NEGOTIATION_STAGES},                         
               {:id=>22, :name=>"Uppbyggingarstyrkir", :negotiation_stages=>NEGOTIATION_STAGES},                         
               {:id=>23, :name=>"Réttarvarsla og grundvallarréttindi", :negotiation_stages=>NEGOTIATION_STAGES},                         
               {:id=>24, :name=>"Dóms- og innanríkismál", :negotiation_stages=>NEGOTIATION_STAGES},                        
               {:id=>25, :name=>"Vísindi og rannsóknir", :negotiation_stages=>NEGOTIATION_STAGES},                         
               {:id=>26, :name=>"Menntun og menning", :negotiation_stages=>NEGOTIATION_STAGES},                        
               {:id=>27, :name=>"Umhverfismál", :negotiation_stages=>NEGOTIATION_STAGES},                        
               {:id=>28, :name=>"Neytenda- og heilsuvernd", :negotiation_stages=>NEGOTIATION_STAGES},                        
               {:id=>29, :name=>"Tollabandalag", :negotiation_stages=>NEGOTIATION_STAGES},                         
               {:id=>30, :name=>"Utanríkistengsl", :negotiation_stages=>NEGOTIATION_STAGES},                         
               {:id=>31, :name=>"Utanríkis-, öryggis- og varnarmál", :negotiation_stages=>NEGOTIATION_STAGES},                         
               {:id=>32, :name=>"Fjárhagslegt eftirlit", :negotiation_stages=>NEGOTIATION_STAGES},                         
               {:id=>33, :name=>"Framlagsmál", :negotiation_stages=>NEGOTIATION_STAGES},                         
               {:id=>34, :name=>"Stofnanir", :negotiation_stages=>NEGOTIATION_STAGES},                        
               {:id=>35, :name=>"Annað", :negotiation_stages=>NEGOTIATION_STAGES},              
               {:id=>36, :name=>"Eldra efni", :negotiation_stages=>NEGOTIATION_STAGES}
        ]

 TREATY_CHAPTER_DESCRIPTION = [
               {:name=>"Frjálst vöruflæði", :desc=>"<h1>Frjálst vöruflæði</h1>Viðskipti með vörur eiga að ganga hindranalaust fyrir sig á innri markaði ESB og Evrópska efnahagssvæðisins (EES). Uppistaðan í þessum kafla ESB löggjafarinnar er hin samræmda regluskrá ESB um framleiddar vörur, sem skylt er að innleiða í löggjöf umsóknarríkisins. Gerðar eru kröfur á að umsóknarríki sýni fram á að það búi yfir nauðsynlegum stjórnsýslulegum styrk til að gera viðvart um hömlur gegn frjálsum vöruviðskiptum og til að hrinda í framkvæmd fylgiaðgerðum á borð við staðla, uppruna og gæðavottun, löggildingu mælitækja, markaðseftirlit og fleira."},
               {:name=>"Frjáls för vinnuafls", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti"},
               {:name=>"Staðfesturéttur og þjónustufrelsi", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti"},
               {:name=>"Frjáls för fjármagns", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti"},
               {:name=>"Opinber útboð", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti"},
               {:name=>"Félagaréttur", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti"},
               {:name=>"Hugverkaréttur", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti"},
               {:name=>"Samkeppnismál", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti"},
               {:name=>"Fjármálaþjónusta", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti"},
               {:name=>"Upplýsingatækni og fjölmiðlun", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" },
               {:name=>"Landbúnaðar- og byggðastefna", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" },                        
               {:name=>"Matvæla- og hreinlætismál", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" },                         
               {:name=>"Fiskveiðar", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti"},                        
               {:name=>"Samgöngur", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti"},                         
               {:name=>"Orka", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti"},                        
               {:name=>"Skattamál", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti"},                         
               {:name=>"Gjaldmiðilssamstarf", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti"},                         
               {:name=>"Hagtölur", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" },                        
               {:name=>"Félagsmála- og atvinnustefna", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" },                        
               {:name=>"Iðnstefna", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" },                         
               {:name=>"Evrópsk samgöngunet", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" },                         
               {:name=>"Uppbyggingarstyrkir", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" },                         
               {:name=>"Réttarvarsla og grundvallarréttindi", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" },                         
               {:name=>"Dóms- og innanríkismál", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" },                        
               {:name=>"Vísindi og rannsóknir", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" },                         
               {:name=>"Menntun og menning", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" },                        
               {:name=>"Umhverfismál", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" },                        
               {:name=>"Neytenda- og heilsuvernd", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" },                        
               {:name=>"Tollabandalag", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" },                         
               {:name=>"Utanríkistengsl", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" },                         
               {:name=>"Utanríkis-, öryggis- og varnarmál", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" },                         
               {:name=>"Fjárhagslegt eftirlit", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" },                         
               {:name=>"Framlagsmál", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" },                         
               {:name=>"Stofnanir", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" },                        
               {:name=>"Annað", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti"},              
               {:name=>"Eldra efni", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti"}
        ]

  def print_all
    TreatyDocument::TREATY_ARRAY.each do |chapter|
      puts chapter[:name]
      chapter[:negotiation_stages].each do |negotion_stage|
        puts negotion_stage[:name]
      end
    end
  end
end