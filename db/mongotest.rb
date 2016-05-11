pipe = [
  { "$match" => {
      timestamp: {
        "$gte" => Time.at(DateTime.now.utc.beginning_of_day),
        "$lte" => Time.at(DateTime.now.utc.end_of_day)
      }
    }
  },
  { "$project" => {
      wh: 1,
      hourly: { "$hour" => "$timestamp" }
    }
  },
  { "$group" => {
    _id: "$hourly",
    wh: { "$last" => "$wh" }
    }
  }
]
hours = Measurement.collection.aggregate(pipe)








pipe = [
  { "$match" => {
      timestamp: {
        "$gte" => Time.at(DateTime.now.utc.beginning_of_day),
        "$lt"  => Time.at(DateTime.now.utc.end_of_day)
      },
      meter_id: {
        "$in" => [1]
      }
    }
  },
  { "$project" => {
      wh: 1,
      hourly: { "$hour" => "$timestamp" }
    }
  },
  { "$group" => {
      _id: "$hourly",
      firstReading: { "$last"  => "$wh" },
      lastReading: { "$first" => "$wh" }
    }
  },
  { "$project" => {
      hourReading: { "$subtract" => [ "$firstReading", "$lastReading" ] }
    }
  },
  { "$sort" => {
      _id: 1
    }
  }
]
hours = Measurement.collection.aggregate(pipe)



[{"_id"=>0, "hourReading"=>702},
 {"_id"=>1, "hourReading"=>584},
 {"_id"=>2, "hourReading"=>523},
 {"_id"=>3, "hourReading"=>415},
 {"_id"=>4, "hourReading"=>480},
 {"_id"=>5, "hourReading"=>179},
 {"_id"=>6, "hourReading"=>276},
 {"_id"=>7, "hourReading"=>245},
 {"_id"=>8, "hourReading"=>230},
 {"_id"=>9, "hourReading"=>539},
 {"_id"=>10, "hourReading"=>392},
 {"_id"=>11, "hourReading"=>618},
 {"_id"=>12, "hourReading"=>499},
 {"_id"=>13, "hourReading"=>952},
 {"_id"=>14, "hourReading"=>1016},
 {"_id"=>15, "hourReading"=>645},
 {"_id"=>16, "hourReading"=>416},
 {"_id"=>17, "hourReading"=>322},
 {"_id"=>18, "hourReading"=>629},
 {"_id"=>19, "hourReading"=>633},
 {"_id"=>20, "hourReading"=>903},
 {"_id"=>21, "hourReading"=>744},
 {"_id"=>22, "hourReading"=>677},
 {"_id"=>23, "hourReading"=>657}]










pipe = [
  { "$match" => {
      timestamp: {
        "$gte" => Time.at(DateTime.now.utc.beginning_of_day),
        "$lt"  => Time.at(DateTime.now.utc.end_of_day)
      }
    }
  },
  { "$project" => {
      wh: 1,
      hourly: { "$hour" => "$timestamp" }
    }
  },
  { "$group" => {
      _id: "$hourly",
      firstReading: { "$last"  => "$wh" },
      lastReading: { "$first" => "$wh" }
    }
  },
  { "$project" => {
      hourReading: { "$subtract" => [ "$firstReading", "$lastReading" ] }
    }
  },
  { "$sort" => {
      _id: 1
    }
  }
]
hours = Measurement.collection.aggregate(pipe)





db.measurements.aggregate([
    { "$match" : { "timestamp": { "$gte": ISODate('2014-03-12 00:00:00'), "$lt": ISODate('2014-03-12 23:59:59') } } },

    { "$project": {
        "wh": 1,
        "hourly": { "$hour": "$timestamp" }
    }},
    { "$group": {
       "_id": "$hourly",
       "firstReading": { "$last": "$wh" },
       "lastReading": { "$first": "$wh" }
    }},
    { "$project": {
       "hourReading": { "$subtract": [ "$firstReading", "$lastReading" ] }
    }},
    { "$sort": { "_id": 1 } }
])






pipe = [

  { "$match" => {
      timestamp: {
        "$gte" => Time.at(DateTime.now.utc.beginning_of_day + 12.hour),
        "$lte" => Time.at(DateTime.now.utc.end_of_day - 2.hour)
      }
    }
  },
  { "$project" => {
      wh: 1,
      hourly: {
        "$subtract" => [
          "$timestamp",
          { "$mod" => [ "$timestamp", 3600 ] }
        ]
      }
    }
  }

]


Measurement.collection.aggregate(pipe).count








Measurement.collection.aggregate([
    { "$match" => {
      timestamp: => {
        "$gte" => DateTime.now.utc.beginning_of_day.to_i,
        "$lte" => DateTime.now.utc.end_of_day.to_i
        }
      }
    },
    { "$project" => {
        wh: 1,
        hourly: {
          "$subtract" => [
            "$timestamp",
            { "$mod" => [ "$timestamp", 3600 ] }
          ]
        }
      }
    }
  ])






mongo

use buzzn_development


db.measurements.aggregate([{ "$match" : { "timestamp": { "$gte": ISODate('2014-03-12 00:00:00'), "$lt": ISODate('2014-03-12 23:59:59')  } } }])






db.measurements.aggregate([
    { "$match" : { "timestamp": { "$gte": ISODate('2014-03-12 00:00:00'), "$lt": ISODate('2014-03-12 23:59:59') } } },

    { "$project": {
        "wh": 1,
        "hourly": { "$hour": "$timestamp" }
    }},
    { "$sort": { "hourly": 1 } },
    { "$group": {
       "_id": "$hourly",
       "wh": { "$last": "$wh" }
    }}
])




db.measurements.aggregate([
    { "$match" : { "timestamp": { "$gte": ISODate('2014-03-12 00:00:00'), "$lt": ISODate('2014-03-12 23:59:59') } } },

    { "$project": {
        "wh": 1,
        "hourly": { "$hour": "$timestamp" }
    }},
    { "$group": {
       "_id": "$hourly",
       "firstReading": { "$last": "$wh" },
       "lastReading": { "$first": "$wh" }
    }},
    { "$project": {
       "hourReading": { "$subtract": [ "$firstReading", "$lastReading" ] }
    }},
    { "$sort": { "_id": 1 } },
])











date        = Time.now
start_time  = date.beginning_of_day
end_time    = date.end_of_day
Reading.test( start_time, end_time)

hour = start_time
watt_hours = []
while hour < end_time
  watt_hours << Reading.where(:register_id => 1, :timestamp.gte => hour, :timestamp.lt => hour.end_of_hour).last.watt_hour
  hour += 1.hour
end

puts watt_hours

Reading.test( start_time, end_time)


Reading.where(:register_id => 1, :timestamp.gte => start_time, :timestamp.lte => end_time).size

Reading.where(:register_id => 1, :timestamp.gte => date.middle_of_day-3.minutes, :timestamp.lt => date.middle_of_day+30.minutes).size






mongo
use buzzn_development

db.readings.aggregate([
    { "$match" : {
        "timestamp": { "$gte": ISODate('2014-07-07T00:00:00+02:00'), "$lt": ISODate('2014-07-07T23:59:59+02:00') },
        "register_id": { "$in": [1] }
    }},
    { "$project": {
        "watt_hour": 1,
        "dayly": {"$dayOfMonth": "$timestamp" },
        "hourly": { "$hour": "$timestamp" }
    }},
    { "$group": {
       "_id": { "dayly": "$dayly", "hourly": "$hourly"},
       "firstReading": { "$last": "$watt_hour" },
       "lastReading": { "$first": "$watt_hour" }
    }},
    { "$project": {
      "hourReading": { "$subtract": [ "$firstReading", "$lastReading" ] }
    }},
    { "$sort": { "_id": 1 } },
])

# "_id": { "hourly": "$hourly", "dayly": "$dayly"},


db.readings.aggregate([
  { "$match" : {
      "timestamp": { "$gte": ISODate('2014-07-07T00:00:00+02:00'), "$lt": ISODate('2014-07-07T23:59:59+02:00')  },
      "register_id": { "$in": [1] }
  }},
  { "$project": {
      "watt_hour": 1,
      "year": { "$year": "$timestamp" },
      "month":  {"$month": "$timestamp" },
      "day":    {"$dayOfMonth": "$timestamp" },
      "hour": { "$hour": "$timestamp" },
      "time": "$timestamp"
  }}
])



db.readings.aggregate([
  { "$match" : {
      "timestamp": { "$gte": ISODate('2014-07-07T00:00:00+02:00'), "$lt": ISODate('2014-07-07T23:59:59+02:00')  },
      "register_id": { "$in": [1] }
  }},
  { "$project": {
      "watt_hour": 1,
      "hourly": { "$hour": "$timestamp" }
      "year":   {"$year": "$timestamp" },
      "month":  {"$month": "$timestamp" },
      "day":    {"$day": "$timestamp" }
  }}
])


# smartmeter tester
db.readings.aggregate([{ "$match" : { "timestamp": { "$gte": ISODate('2014-08-04T21:59:00'), "$lt": ISODate('2014-08-04T23:59:59')  },"register_id": { "$in": [1] } } }])
# { "_id" : ObjectId("53deb1056666618cae9f0500"), "register_id" : 1, "timestamp" : ISODate("2014-08-04T21:59:00Z"), "watt_hour" : 7446 }
# lezter 22 uhr

# slp
db.readings.aggregate([{ "$match" : { "timestamp": { "$gte": ISODate('2014-12-31T21:59:59'), "$lt": ISODate('2014-12-31T23:59:59')  },"source": { "$in": ['slp'] } } }])
# { "_id" : ObjectId("53deb17e6666618caeffd100"), "timestamp" : ISODate("2014-12-31T22:45:00Z"), "watt_hour" : 999999, "source" : "slp" }
# lezter 23 uhr



db.readings.aggregate(
    {"$project": {
         "year": { "$year": "$timestamp"},
         "month": { "$month": "$timestamp"}
    }},
    {"$group": {
         "_id": {"year" : "$year", "month": "$month"},
         "count": {"$sum": 1}
    }}
)











map = %Q{
  function() {
    var quarter;
    var mins = this.time.getMinutes();
    if(mins <= 14)
    	quarter = 0;
    else if(mins<=29)
    	quarter = 15;
    else if(mins<=44)
    	quarter = 30;
    else
    	quarter = 45;
      var time_at_minute = new Date(this.time.getFullYear(),
          this.time.getMonth(),
          this.time.getDate(),
          this.time.getHours(),
          quarter);

    emit(time_at_minute, {
    	count: 1,
    	power: this.power,
    	volume: this.amount,
    	total: this.total,
    	low: this.power,
    	high: this.power,
    	open: this.power,
    	close: this.power,
    });
  }
}

reduce = %Q{
  function(key, values) {
    var powers = 0.0;
    var volume = 0.0;
    var total = 0.0;
    var high = values[0].power;
    var low = values[0].power;
    var count = 0;
    values.forEach(function(value)
    {
      powers += value.power;
      volume+= value.volume;
      total+= value.total;
      if(value.power > high)
        high = value.power;
      if(value.power < low)
        low = value.power;
        count+=1;
    });
    var result = {
      open: values[0].power,
      close: values[values.length-1].power,
      high: high,
      low: low,
      power: powers/count,
      volume: volume,
      total: total,
      count: count,
    };
    return result;
  }
}


Reading.where( source: 'slp', :time.gte => Time.new(2016,2,1).beginning_of_month ).map_reduce(map, reduce).out(inline: true).each do |document|
  p document
end
