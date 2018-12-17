# fake some discovergy data

def serialized_reading(time, power, energy, energy_out = nil)
  json = {
    time: time,
    values: {
      power: power,
      energy: energy
    }
  }
  json[:values][:energyOut] = energy_out if energy_out
  json
end

def create_series(start_time, power, increment_time, initial_energy, increment_energy, steps)
  steps || 1
  steps.times.collect { |x| serialized_reading(start_time + increment_time*x, power, initial_energy + increment_energy*x) }
end
