class Offering < ActiveRecord::Base
  belongs_to :practice_area,
    :touch => true
  belongs_to :user,
    :touch => true

    
   #solr index
    searchable do
     text :description 
     text :name 
     text :practice_area do
       practice_area.name if !!practice_area
     end
     text :user
     text :state_name do
       get_state_name
     end
    end 
    
    def get_state_name
      Lawyer.find(self.user.id).states.map(&:name)*","
    end
       
    def reindex!
       Sunspot.index!(self)
    end
    
    def self.build_search(query)
      search = Sunspot.new_search(Offering)
      search.build do
        fulltext query
        paginate :per_page => 100
      end
      search
    end
    
end

