class DataPoint
  DataPointKey = 'hash_data'

  def self.range(start, finish)
    $redis.zrangebyscore(DataPointKey, start.to_i, finish.to_i, with_scores: true).map { |a| {time: a[1].to_i, value: a[0].to_i} }
  end

  def self.add(date, value)
    $redis.zadd(DataPointKey, date.to_i, value)
    $redis.zremrangebyscore(DataPointKey, 0, 1.year.ago.to_i)
    # Todo: better cleanup here
    # Aggregate older items into averages, etc.
  end
end