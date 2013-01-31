# encoding: utf-8

require "bundler/setup"
require "gaminator"

class Snake

	class Segment < Struct.new(:x, :y)
    	def char
      	"#"
    	end

    	def color
    		Curses::COLOR_RED
    	end
  	end

  	class Apple < Struct.new(:x, :y)
    	def char
      	"@"
    	end

    	def color
    		Curses::COLOR_GREEN
    	end
  	end

	def initialize(width, height)
		@body = [Segment.new(width/2, height/2)]
		@width = width
		@height = height
		@apples = [Apple.new(10, 10), Apple.new(20,20), Apple.new(50,30), Apple.new(40,10)]
		@dir = :left
		@points  = 0
		@rand = Random.new
		@tickCount = 0
		@difficulty = 1;
	end

	def tick

		move

		handle_collisions

        if @tickCount % 25 == 0
        	generate_apple
        	reset_tick_counter
        end

        @tickCount = @tickCount + 1
    end

	def move
		first = @body.first
		case @dir
			when :left
				if first.x-1 > 0
					head = Segment.new(first.x-1, first.y)
				else
					head = Segment.new(@width-1, first.y)
				end	
			when :right
				if (first.x+1 > @width-1)
					head = Segment.new(1, first.y)
				else
					head = Segment.new(first.x+1, first.y)
				end	
			when :down
				if first.y + 1 > @height-1
					head = Segment.new(first.x, 0)
				else
					head = Segment.new(first.x, first.y+1)
				end
			when :up
				if first.y-1 > 0
					head = Segment.new(first.x, first.y-1)
				else
					head = Segment.new(first.x, @height-1)
				end
			end 
		@body = [head] + @body
	end

	def handle_collisions
		if collision? @apples
			@points = @points + 1
			level_up
		else
			@body = @body[0..-2]
		end

		if collision? @body[1..-1]
			end_game
		end

		@apples = @apples.select do |apple|
			apple.y != @body.first.y ||
        	apple.x != @body.first.x
        end
	end

	def level_up
		@difficulty = @difficulty + 1
	end

	def end_game
		Kernel.exit
	end

	def reset_tick_counter
		@tickCount = 0
	end

	def generate_apple
		@apples = @apples + [Apple.new(@rand.rand(@width), @rand.rand(@height))]
	end

	def collision? (colliding_object)
		colliding_object.any? {|apple| head_collide_with apple }
	end

	def head_collide_with(object)
		object.x == @body.first.x &&
		object.y == @body.first.y
	end

	def render_objects

	end

	def objects
    	@body + @apples
 	end

 	def textbox_content
    	"Score: %d" % @points
  	end

  def input_map
    {
      ?a => :move_left,
      ?d => :move_right,
      ?w => :move_up,
      ?s => :move_down,
      ?q => :exit,
    }
  end

  def move_left
  	@dir = :left unless @dir == :right
  end

  def move_right
  	@dir = :right unless @dir == :left
  end

  def move_down
  	@dir = :down unless @dir == :up
  end

  def move_up
  	@dir = :up unless @dir == :down
  end

  def sleep_time
  	case @dir
  	when :left, :right
    	0.1 / @difficulty
    when :up, :down
    	0.2 / @difficulty
    end
  end

  	def wait?
    	false
  	end

	def exit_message
		"You've lost. Score %d" % @points
	end
end

Gaminator::Runner.new(Snake).run
