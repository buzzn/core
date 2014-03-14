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

