class DailyHour < ActiveRecord::Base
  belongs_to :lawyer

  validates :end_time,
    :presence => true,
    :numericality => {
      :only_integer => true,
      :greater_than_or_equal_to => -1,
      :less_than_or_equal_to => 2400
    }

  validates :start_time,
    :presence => true,
    :numericality => {
      :only_integer => true,
      :greater_than_or_equal_to => -1,
      :less_than_or_equal_to => 2400
    }

  validates :wday,
    :presence => true,
    :uniqueness =>  {:scope => :lawyer_id},
    :numericality => {
      :only_integer => true,
      :greater_than_or_equal_to => 0,
      :less_than_or_equal_to => 6,
      :message => "must be a valid day of the week (0-6)"
    }

  validate :check_times

  protected
  # validation of start time and end time
  # make sure start time is before end time
  # make sure neither or both is -1 but not a mixture
  def check_times
    times = [self.start_time.to_i, self.end_time.to_i]
    closed_error = "You must mark both the start time and end " +
      "time as closed for a day."
    # if either day is closed
    if times.any?{|i| i == -1} 
      # and not both are closed
      unless times.all?{|i| i == -1}
        self.errors.add(:base, closed_error)
      end
    # otherwise, check if the start time is before the end time
    elsif self.start_time.to_i >= self.end_time.to_i
      self.errors.add(:base, "Start time must be before end time.")
    end
  end
end
