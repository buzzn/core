class CalculateGroupScoreClosenessWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :dead => false

  def perform(group_id)
    @group = Group.find(group_id)
    addresses_out = @group.metering_points.where(mode: 'out').collect(&:address).compact
    addresses_in = @group.metering_points.where(mode: 'in').collect(&:address).compact
    sum_distances = 0
    addresses_in.each do |address_in|
      addresses_out.each do |address_out|
        sum_distances += address_in.distance_to(address_out)
      end
    end
    if addresses_out.count * addresses_in.count != 0
      average_distance = sum_distances / (addresses_out.count * addresses_in.count)
      if average_distance < 10
        @group.closeness = 5
      elsif average_distance < 20
        @group.closeness = 4
      elsif average_distance < 50
        @group.closeness = 3
      elsif average_distance < 200
        @group.closeness = 2
      elsif average_distance >= 200
        @group.closeness = 1
      else
        @group.closeness = 0
      end
    else
      @group.closeness = nil
    end
    @group.save
  end


end