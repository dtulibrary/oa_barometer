module BarometerHelper
  def calculate_percentage(count, total, multiply=false)
    return ((count.to_f/total.to_f)*100).round if multiply
    return (count.to_f/total.to_f)
  end
end
