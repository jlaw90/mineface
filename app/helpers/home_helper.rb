module HomeHelper
  def get_data(start, interval)
    # Select data that fits our range
    data = DataPoint.where(created_at: start...DateTime.now.getutc).sort_by(&:created_at)
    interval = interval.to_i
    startmin = start.to_i

    # Group the data by our interval
    grouped = data.group_by do |dp|
      utime = dp.created_at.to_i - startmin
      utime / interval
    end

    # Average and return as time, value pairs
    grouped.map do |idx, bucket|
      sum = bucket.map(&:value).reduce(:+)
      avg = sum / bucket.length
      time = Time.at(startmin + idx * interval)
      [time, avg]
    end
  end
end