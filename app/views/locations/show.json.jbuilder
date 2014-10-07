json.location do
  json.id @location.id
  json.metering_points @location.metering_point.subtree.arrange
end