class LawyerDecorator < ApplicationDecorator

  decorates :lawyer,
    :class => "Lawyer"


  def licensed_states
    self.lawyer.states.collect(&:abbreviation).to_sentence
  end

  def long_personal_tagline
    escaped_tagline = h.escape_once(self.lawyer.personal_tagline)
    link = h.link_to(
      'read more', h.attorney_path(self.lawyer, slug: self.lawyer.slug)
    )
    line = escaped_tagline.truncate(
      600, 
      separator: ' ', 
      omission: "... #{link}"
    )
    "&quot;#{line}&quot;".html_safe
  end

  # Lawyer's photo linking to his page
  def photo
    h.link_to(
      h.image_tag(lawyer.photo.url(:thumb)), 
      h.attorney_path(lawyer, slug: lawyer.slug)
    )
  end

  def photo_url(type)
    self.lawyer.photo.url(type)
  end

  # List of practice area names as a sentence
  def practice_area_names
    names = self.lawyer.parent_practice_areas.collect(&:name)
    names.to_sentence.downcase
  end

  def short_personal_tagline
    escaped_tagline = h.escape_once(self.lawyer.personal_tagline)
    line = escaped_tagline.truncate(
      120, 
      separator: ' ', 
      omission: "... <span class='read_more'>read more</span>"
    )
    "&quot;#{line}&quot;".html_safe
  end

end