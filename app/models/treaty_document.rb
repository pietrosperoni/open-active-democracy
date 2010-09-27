class TreatyDocument < ActiveRecord::Base

NEGOTIATION_STAGES = [
                      {:id=>1, :name=>Rikjaradstefna},
            {:id=>2, :name=>"Fyrri rynifundur: afstada ESB"}
           ]
TREATY_ARRAY = [
                {:id=>1, :name=>"Frjálst vöruflæði", :negotiation_stages=>NEGOTIATION_STAGES},
                {:id=>2, :name=>"Frjáls för vinnuafls", :negotiation_stages=>NEGOTIATION_STAGES}
         ]
end
