# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://www.lawdingo.com"

SitemapGenerator::Sitemap.create do
  lastmod = Lawyer.order(:updated_at=>:desc).limit(1).first.updated_at
  add lawyers_path, :lastmod => lastmod, :changefreq => 'daily', :priority => 0.8

  add about_page_path
  add about_attorneys_path
  add terms_page_path
  add pricing_process_path
  add new_lawyer_path
  add new_clients_path
  
   ['Legal-Advice','Legal-Services'].each do |type|
     add lawyers_path + "/#{type}/All-States", :lastmod => lastmod, :changefreq => 'weekly', :priority => 0.8
     add state_path(:service_type =>type, :state => 'All-states'), :lastmod => lastmod, :changefreq => 'weekly', :priority => 0.8
     State.with_approved_lawyers.each do |state|
       add state_path(:service_type =>type, :state => state.name_for_url), :lastmod => lastmod, :changefreq => 'weekly', :priority => 0.8
       PracticeArea.parent_practice_areas.with_approved_lawyers.each do |area|
         add filtered_path(:service_type => type, :practice_area => area.name_for_url), :lastmod => lastmod, :changefreq => 'weekly', :priority => 0.8 
         add filtered_path(:service_type => type, :state => state.name_for_url, :practice_area => area.name_for_url), :lastmod => lastmod, :changefreq => 'weekly', :priority => 0.8 
         area.children.with_approved_lawyers.each do |child_area|
           add lawyers_path + "/#{type}/All-states/#{child_area.name_for_url}", :lastmod => lastmod, :changefreq => 'weekly', :priority => 0.8
           add lawyers_path + "/#{type}/#{state.name_for_url}/#{child_area.name_for_url}", :lastmod => lastmod, :changefreq => 'weekly', :priority => 0.8
         end if type.eql?('Legal-Advice')
       end
     end
   end

  Lawyer.approved_lawyers.find_in_batches do |lawyers|
       lawyers.each do |lawyer|
        add attorney_path(lawyer, slug: lawyer.slug), :lastmod => lawyer.updated_at, :changefreq => 'monthly', :priority => 0.8
      end
   end
   
   Offering.find_in_batches do |offerings| 
     offerings.each do |offering|
       add offering_path(offering), :lastmod => offering.updated_at, :changefreq => 'monthly', :priority => 0.8
     end
   end
  #
end

