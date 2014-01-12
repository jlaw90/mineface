scheduler = Rufus::Scheduler.new

# Add a datapoint to redis
scheduler.every("1m") do
  devs = Api.create.devices
  return if devs.empty?
  val = devs.map { |dev| dev[:mhs_5s] }.reduce(:+)
  DataPoint.add(DateTime.now, val)
end

# Schedule donation to occur every day at midnight
scheduler.cron '0 0 * * *' do
  DonationHelper.donate_mode = true

  # Wait 30 seconds so that the ui is definitely refreshed - TODO HACK

  donation_pools = [
      {url: 'http://pool.50btc.com:8332', worker: 'jlaw90@hotmail.com_donate', pass: 'nawt'},
      {url: 'http://us.eclipsemc.com:8337', worker: 'jlaw90_donation', pass: 'nawt'}
  ]

  api = Api.create
  old_pools = api.pools

  donation_pools.each do |pool|
    p.addpool(p[:url], p[:user], p[:pass])
  end

  old_pools.each do |pool|

  end

  # Don't forget to reset this!
  DonationHelper.donate_mode = false
end
