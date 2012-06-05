class Offering < ActiveRecord::Base
  belongs_to :practice_area,
    :touch => true
  belongs_to :user,
    :touch => true

    
    #solr index
    searchable do
     text :description 
     text :name 
     text :practice_area 
     text :user
    end 
       
    def reindex!
       Sunspot.index!(self)
    end
    
    def self.build_search(query)
      search = Sunspot.new_search(Offering)
      search.build do
        fulltext query
      end
      search
    end
    
end

