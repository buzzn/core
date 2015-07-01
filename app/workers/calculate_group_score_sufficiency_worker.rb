class CalculateGroupScoreSufficiencyWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :dead => false

  def perform(group_id, resolution_format, containing_timestamp)
    @group = Group.find(group_id)
    count_sn_in_group = 0
    @group.metering_points.each do |metering_point|
      count_sn_in_group += metering_point.users.count if metering_point.input?
      #TODO: enable virtual metering_points
    end
    #result_in = @group.convert_to_array_build_timestamp(Reading.aggregate(resolution_format, @group.metering_points.where(mode: "in").collect(&:id), containing_timestamp), resolution_format, containing_timestamp).flatten
    chart_data = @group.chart(resolution_format, containing_timestamp)
    result_in = chart_data[0][:data]
    if result_in.empty?
      return
    end
    if count_sn_in_group != 0
      sufficiency = @group.extrapolate_kwh_pa(result_in[1], resolution_format, containing_timestamp)/count_sn_in_group
    else
      sufficiency = nil
    end
    interval_information = @group.set_score_interval(resolution_format, containing_timestamp)
    if sufficiency < 500
      value = 5
    elsif sufficiency < 900
      value = 4
    elsif sufficiency < 1500
      value = 3
    elsif sufficiency < 2300
      value = 2
    elsif sufficiency >= 2300
      value = 1
    else
      value = 0
    end
    Score.create(mode: 'sufficiency', interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: value, scoreable_type: 'Group', scoreable_id: group_id)
  end


end