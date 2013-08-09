scheduler = Rufus::Scheduler.start_new

def add_point
  devs = Api.create.devices
  return if devs.empty?
  val = devs.map { |dev| dev[:mhs_5s] }.reduce(:+)
  DataPoint.add(DateTime.now, val)
end

scheduler.every("1m") do
  add_point
end