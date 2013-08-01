# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

min = 0
max = 8000
range = max - min

mindate = DateTime.now.beginning_of_month.to_i
maxdate = DateTime.now.to_i
rangedate = maxdate - mindate

times = 1000

times.times do |i|
  f = i.to_f / times.to_f
  dp = DataPoint.new
  dp.value = min + range * f
  dp.created_at = Time.at(mindate.to_i + rangedate * f).to_datetime
  dp.save!
end