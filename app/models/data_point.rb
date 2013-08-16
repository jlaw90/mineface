class DataPoint
  REDIS_KEY = 'hash_data'

  def self.range(start, finish)
    $redis.zrangebyscore(REDIS_KEY, start.to_i, finish.to_i, with_scores: true).map { |a| {time: a[1].to_i, value: a[0].to_f} }
  end

  def self.add(date, value)
    $redis.zadd(REDIS_KEY, date.to_i, value)
    $redis.zremrangebyscore(REDIS_KEY, 0, 1.year.ago.to_i)
  end
end