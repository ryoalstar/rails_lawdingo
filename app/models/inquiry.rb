class Inquiry < ActiveRecord::Base
  belongs_to :question
  has_many :bids

  scope :opened, where(is_closed: false)

  def expiration(date_part)
    case date_part.to_sym
    when :year
      created_at.year
    when :month
      created_at.month.to_i - 1
    when :day
      created_at.day
    when :hours
      created_at.strftime("%k").to_i + 12
    when :minutes
      created_at.strftime("%M").to_i
    when :seconds
      created_at.strftime("%S").to_i
    else
      expired_at
    end
  end

  def expired_at
    self.created_at + 12.hours
  end

  def expired?
    Time.now > self.expired_at
  end

  def minimum_bid
    if bids.any? && bids.count > 2
      bids[-3].amount + 1
    else
      1
    end
  end

  def winners
    winners = []
    bids.reverse_order.limit(3).each do |bid|
      winners << bid.lawyer
    end

    winners
  end

  def charge_winners
    bids.reverse_order.limit(3).each do |bid|
      bid.charge
    end
  end

  def close
    UserMailer.closed_inquiry_notification(self).deliver
    update_attributes({ is_closed: true })
  end

  class << self
    def close_expired
      Inquiry.opened.each do |inquiry|
        if inquiry.expired?
          inquiry.charge_winners
          inquiry.close
        end
      end
    end
  end
end
