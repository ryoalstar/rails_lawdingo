DynamicSitemaps::Sitemap.draw do
  
  # default page size is 50.000 which is the specified maximum at http://sitemaps.org.
   per_page 5000

   url root_url, :last_mod => DateTime.now, :change_freq => 'daily', :priority => 1

   new_page!

   User.all.each do |user|
     url user_url(user), :last_mod => user.updated_at, :change_freq => 'monthly', :priority => 0.8
   end

   new_page!

   autogenerate  :users, :offerings, :pages

end