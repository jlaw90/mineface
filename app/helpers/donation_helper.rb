module DonationHelper
  def self.donate_mode?
    begin
      $redis.getbit('miner.donate', 0) == 1
    rescue
      return false
    end
  end

  def self.donate_mode=(val)
    begin
      $redis.setbit('miner.donate', val ? 1 : 0)
    rescue
      return false
    end
  end
end