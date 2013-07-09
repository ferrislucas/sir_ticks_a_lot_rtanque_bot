class SirTicksALotBot < RTanque::Bot::Brain
  NAME = 'sir ticks a lot'
  include RTanque::Bot::BrainHelper
  TURRET_FIRE_RANGE = RTanque::Heading::ONE_DEGREE * 5.0

  def tick!
    command.heading = sensors.heading + (RTanque::Heading::ONE_DEGREE * 90)
    command.speed = MAX_BOT_SPEED

    if (lock = self.get_radar_lock)
      destroy_lock(lock)
      #@desired_heading = nil
    #else
      #self.seek_lock
    end
  end

  def destroy_lock(reflection)
    #command.heading = reflection.heading
    command.radar_heading = reflection.heading
    command.turret_heading = reflection.heading
    #command.speed = reflection.distance > 200 ? MAX_BOT_SPEED : MAX_BOT_SPEED / 2.0
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
end
