module BarometerHelper
  def calculate_percentage(count, total, multiply=false)
    return ((count.to_f/total.to_f)*100).to_i if multiply
    return (count.to_f/total.to_f)
  end
end
