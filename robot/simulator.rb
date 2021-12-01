class InvalidCommandError < ::StandardError
end

class ArgumentError < ::StandardError
end

module Robot
  class Simulator
    attr_accessor :command, :args

    BOX_LENGTH_X = 5
    BOX_LENGTH_Y = 5
    DIRECTIONS = %w[NORTH EAST SOUTH WEST].freeze

    def self.run
      command = gets # First input from user
      simulator = new(command)
      simulator.perform
    end

    def initialize(cmd)
      sanitize(cmd)
    end

    def perform
      validate_place_command

      set_origin
      set_default_origin unless @result

      until command == 'REPORT'
        cmd = gets
        sanitize(cmd)
        log_movement
      end
    end

    private

    def sanitize(cmd)
      @command, @args = cmd.split(' ')
      @args = @args.strip.split(',') if @args
    end

    def validate_place_command
      raise InvalidCommandError if command != 'PLACE' || !DIRECTIONS.include?(args[2])
      raise ArgumentError unless args && args.size == 3
    end

    def log_movement
      case command

      when 'MOVE'
        move
      when 'LEFT', 'RIGHT'
        rotate
      when 'PLACE'
        set_origin(args[0].to_i, args[1].to_i, args[2])
      when 'REPORT'
        report
      else
        raise InvalidCommandError
      end
    end

    def report
      puts "\n"
      puts @result.values.join(',')
    end

    def rotate
      position = DIRECTIONS.find_index(@result[:f])
      position = (position + 1) % 4 if command == 'RIGHT' # clockwise
      position = (position - 1) % 4 if command == 'LEFT' # anti-clockwise

      @result[:f] = DIRECTIONS[position] # rotate 90 degree
    end

    def move
      facing = @result[:f]

      # forward direction
      @result[:x] += 1 if facing == 'EAST' && @result[:x] < BOX_LENGTH_X # Ignore movement if outside the table
      @result[:y] += 1 if facing == 'NORTH' && @result[:y] < BOX_LENGTH_Y

      # backward direction
      @result[:x] += -1 if facing == 'WEST'
      @result[:y] += -1 if facing == 'SOUTH'
    end

    def set_origin
      x = args[0].to_i
      y = args[1].to_i
      dir = args[2]

      return if x > BOX_LENGTH_X || y > BOX_LENGTH_Y # Ignoring command from robot falling

      @result = { x: x, y: y, f: dir }
    end

    def set_default_origin
      @result = { x: 0, y: 0, f: 'NORTH' }
    end
  end
end

Robot::Simulator.run # run
