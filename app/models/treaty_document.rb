class TreatyDocument < ActiveRecord::Base

  MAXIMUM_NUMBER_OF_DOCUMENTS = 15

  NEGOTIATION_STAGES = [
                     {:id=>1, :name=>"Rikjaradstefna"},
                     {:id=>2, :name=>"Fyrri rýnifundur: afstada ESB"},
                     {:id=>3, :name=>"Seinni rýnifundur: afstaða Íslands"},
                     {:id=>4, :name=>"Niðurstaða rýnifunda"},
                     {:id=>5, :name=>"Samningsafstaða ESB"},
                     {:id=>6, :name=>"Samningsafstaða Íslands"},
                     {:id=>7, :name=>"Benchmark skilyrði"},
                     {:id=>8, :name=>"Opnun kafla"},
                     {:id=>9, :name=>"Samningar"},
                     {:id=>10, :name=>"Benchmark Closing"},
                     {:id=>11, :name=>"Lokun kafla"}
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
               {:id=>0, :name=>"Eldra efni", :negotiation_stages=>NEGOTIATION_STAGES}
        ]

#using name as index
 TREATY_CHAPTER_DESCRIPTION_BYNAME = [
               {:name=>"Frjálst vöruflæði", :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti"},
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

# in use!!!
  TREATY_CHAPTER_DESCRIPTION = [
                     {:id=>1, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                      {:id=>2, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                       {:id=>3, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                        {:id=>4, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                         {:id=>5, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                          {:id=>6, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                           {:id=>7, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                            {:id=>8, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                             {:id=>9, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                              {:id=>10, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                               {:id=>11, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                                {:id=>12, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" },
                          {:id=>13, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                           {:id=>14, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                            {:id=>15, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                             {:id=>16, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                              {:id=>17, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                               {:id=>18, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                                {:id=>19, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                                 {:id=>20, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                                  {:id=>21, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                                   {:id=>22, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                                    {:id=>23, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                                     {:id=>24, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                                      {:id=>25, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                                       {:id=>26, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                                        {:id=>27, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                                         {:id=>28, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                                          {:id=>29, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                                           {:id=>30, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                                            {:id=>31, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                                             {:id=>32, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                                              {:id=>33, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" }, 
                                               {:id=>34, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" },
                                               {:id=>35, :desc=>"dummytextidummy textidummy textidummy textidummy textidummy texti" },
                     {:id=>0, :desc=>"asdf fdsa asdf fda<br><br>fdslfkldsk fdkslfdskf lds"} 
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