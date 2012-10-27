class LawyerDecorator < ApplicationDecorator

  decorates :lawyer,
    :class => "Lawyer"

end