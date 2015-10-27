class Var < ActiveRecord::Base
  belongs_to :instrument
  belongs_to :measured_property

  def measured_at_parameter
    return self.shortname + '_measured_at'
  end

  def at_parameter
    return self.shortname + '_at'
  end


end
