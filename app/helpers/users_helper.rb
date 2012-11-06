module UsersHelper
  def lawyers_title
    text = []
    text << @selected_state.try(:name) if @selected_state
    text << @practice_area.try(:name) if @practice_area
    text << 'Attorneys Offering' << @service_type.titleize if @service_type
    text << 'on Lawdingo'
    title text.join(' ')
  end
end
