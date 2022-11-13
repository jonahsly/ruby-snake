require_relative "view/ruby2d"
require_relative "model/state"
require_relative "actions/actions"

class App

    def initialize
        @state = Model::initial_state
        @speed = 0.5
    end

    def start
        @view = View::Ruby2dView.new(self)
        timer_thread = Thread.new { init_timer }
        @view.start(@state)
        timer_thread.join
    end

    def init_timer
        snake_length = @state.snake.positions.length
        loop do
            if @state.game_over
                puts "GAME OVER"
                puts "Puntaje: #{@state.snake.positions.length-2}"
                break
            end
            @state = Actions::move_snake(@state)
            @view.renderGame(@state)
            if snake_length < @state.snake.positions.length
                snake_length = @state.snake.positions.length
                increment_speed
            end
            sleep @speed
        end
    end

    def send_action(action, params)
        new_state = Actions.send(action, @state, params)
        if new_state.hash != @state
            @state = new_state
            @view.renderGame(@state)
        end
    end

    private 
    
    def increment_speed
        if @speed > 0.001
            @speed = @speed - (@speed * 0.05)
            if @speed < 0.001
                @speed = 0.001
            end
        end     
    end
end

app = App.new
app.start