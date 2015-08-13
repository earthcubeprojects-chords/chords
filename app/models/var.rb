class Var < ActiveRecord::Base
  belongs_to :instrument

  def measured_at_parameter
    return self.shortname + '_measured_at'
  end

  def at_parameter
    return self.shortname + '_at'
  end


end
