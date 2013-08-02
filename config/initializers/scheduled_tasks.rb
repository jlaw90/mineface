scheduler = Rufus::Scheduler.start_new

def add_point
  $api ||= Api.create
  devs = $api.devs
  return if devs[:status] == :error or devs[:data][:devs].length == 0
  val = devs[:data][:devs].map { |dev| dev[:mhs_5s] }.reduce(:+)
  DataPoint.add(DateTime.now, val)
end

scheduler.every("1m") do
  add_point
end

add_point # Add a point on startup so the graph isn't blank..