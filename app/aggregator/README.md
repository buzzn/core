aggregator = Aggregator.new()
aggregator.watt_hour # gibt die watt_hour_a
aggregator.watt_hour('a') # gibt die watt_hour_a
aggregator.watt_hour('b') # gibt die watt_hour_b
aggregator.power # aktuelle power vom SLP
aggregator.chart # day_to_hours chart von heute als SLP
aggregator.chart('day_to_minutes') # day_to_minutes chart von heute als SLP
aggregator.chart('day_to_minutes', 'Mon, 02 May 2016 18:32:39 +0200') # day_to_minutes chart von history als SLP
aggregator.chart('day_to_minutes', '1462206798') # day_to_minutes chart von history in unixtime als SLP
aggregator.forcast # jahresverbrauch hochrechnung in watt_hour


aggregator = Aggregator.new(['xxx', 'yyy'])
aggregator.watt_hour # gibt die summierte watt_hour_a beider metering_points zuruck.
