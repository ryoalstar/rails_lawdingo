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

  # actual end time on a real date
  def start_time_on_date(date)
    return self.time_on_date(:start_time, date)
  end
  # actual end time on a real date
  def end_time_on_date(date)
    return self.time_on_date(:end_time, date)
  end

  protected
  # helper method to turn get the real start/end time on
  # a given date
  def time_on_date(type, time)
    # make this a time if a Date is given
    time = time.to_time if time.is_a?(Date)
    time = time.in_time_zone
    return nil unless time.wday == self.wday
    hours, minutes = self.send(type).divmod(100)
    time.midnight + hours.hours + minutes.minutes
  end
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
