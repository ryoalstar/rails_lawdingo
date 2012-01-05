class HomepageImage < ActiveRecord::Base
  belongs_to :lawyer, :dependent => :destroy

  has_attached_file :photo, :url => "/:class/:attachment/:id/:style_:basename.:extension",
    :styles => {
      :large  => "437x295"
      }
end

