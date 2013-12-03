module BarometerHelper
  def calculate_percentage(count, total)
    return (count.to_f/total.to_f)
  end
end
