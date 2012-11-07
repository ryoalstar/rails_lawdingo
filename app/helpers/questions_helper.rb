module QuestionsHelper
  def auto_detected_state
    @auto_detected_state ? @auto_detected_state.name : "Not specified"
  end
end
