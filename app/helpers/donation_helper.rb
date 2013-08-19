module DonationHelper
  def self.donate_mode?
    $redis.getbit('miner.donate', 0) == 1
  end

  def self.donate_mode=(val)
    $redis.setbit('miner.donate', val ? 1 : 0)
  end
end