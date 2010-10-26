class TreatyDocument < ActiveRecord::Base

  MAXIMUM_NUMBER_OF_DOCUMENTS = 15

  acts_as_taggable_on :issues

  NEGOTIATION_STAGES = [
                     {:id=>0, :name=>"Umsóknarferli"},
                     {:id=>1, :name=>"Rikjaradstefna"},
                     {:id=>2, :name=>"Rýnivinna"},
                     {:id=>3, :name=>"Viðmið fyrir opnun kafla"},
                     {:id=>4, :name=>"Samningsafstaða Íslands"},
                     {:id=>5, :name=>"Samningsafstaða ESB"},
                     {:id=>6, :name=>"Opnun kafla"},
                     {:id=>7, :name=>"Viðmð fyrir lokun kafla"},
                     {:id=>8, :name=>"Aðildarsamningur"}
          ]
end