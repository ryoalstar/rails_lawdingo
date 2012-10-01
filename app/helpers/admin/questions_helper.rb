module Admin::QuestionsHelper
  def matched_lawyers_count(question)
    if question.matched_lawyers.count > 0
      question.matched_lawyers.count
    else
      0
    end
  end

end
