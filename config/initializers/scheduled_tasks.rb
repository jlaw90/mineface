scheduler = Rufus::Scheduler.start_new

def add_point
  devs = Api.create.devs
  return if devs[:status] == :error or devs[:data][:devs].length == 0
  val = devs[:data][:devs].map { |dev| dev[:mhs_5s] }.reduce(:+)
  DataPoint.add(DateTime.now, val)
end

scheduler.every("1m") do
  add_point
end

add_point