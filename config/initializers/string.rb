class String
  def numeric?
    Float(self) != nil rescue false
  end

  def nl2br
    self.gsub(/\n/, '<br />')
  end
end
