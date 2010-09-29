class TreatyDocument < ActiveRecord::Base

  NEGOTIATION_STAGES = [
                     {:id=>1, :name=>"Rikjaradstefna"},
                     {:id=>2, :name=>"Fyrri rynifundur: afstada ESB"},
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
               {:id=>35, :name=>"Annað", :negotiation_stages=>NEGOTIATION_STAGES}              
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
