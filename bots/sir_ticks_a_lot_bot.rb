class SirTicksALotBot < RTanque::Bot::Brain
  NAME = 'sir ticks a lot'
  include RTanque::Bot::BrainHelper
  TURRET_FIRE_RANGE = RTanque::Heading::ONE_DEGREE * 5.0

  def tick!
    command.heading = sensors.heading + (RTanque::Heading::ONE_DEGREE * 90)
    command.speed = MAX_BOT_SPEED

    if (lock = find_closest_victim)
      destroy_lock(lock)
    else
      command.turret_heading = sensors.heading + (RTanque::Heading::ONE_DEGREE * 33)
      command.radar_heading = command.turret_heading
      command.fire(MIN_FIRE_POWER)
    end
  end

  private

  def destroy_lock(reflection)
    command.radar_heading = reflection.heading
    command.turret_heading = reflection.heading
    if (reflection.heading.delta(sensors.turret_heading)).abs < TURRET_FIRE_RANGE
      command.fire(reflection.distance > 200 ? MAX_FIRE_POWER : MIN_FIRE_POWER)
    end
  end

  def get_radar_lock
    @locked_on ||= nil
    lock = if @locked_on
      sensors.radar.find { |reflection| reflection.name == @locked_on } || sensors.radar.first
    else
      sensors.radar.first
    end
    @locked_on = lock.name if lock
    lock
  end

  def find_closest_victim
    victims = sensors.radar.find#.to_a
    return nil if victims.count == 0
    target = victims.sort_by{|x| x.distance}.first

    #puts "#{victims.map{|c| "#{c.name} (#{c.distance})"}} #{target.name} (#{target.distance})" if victims.count > 1

    return target if target
    nil
  end
end
