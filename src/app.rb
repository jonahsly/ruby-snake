require_relative "view/ruby2d"  # Load the Ruby2D view script
require_relative "model/state"  # Load the game state model
require_relative "actions/actions"  # Load the actions script which contains game logic

class App

    def initialize
        @state = Model::initial_state  # Initialize the game state using a method from the Model module
        @speed = 0.5  # Set the initial speed of the game
    end

    def start
        @view = View::Ruby2dView.new(self)  # Create a new view object for the game
        timer_thread = Thread.new { init_timer }  # Start a new thread to handle game timing
        @view.start(@state)  # Start the game view
        timer_thread.join  # Ensure the timer thread continues running
    end

    def init_timer
        snake_length = @state.snake.positions.length  # Get the initial length of the snake
        loop do
            if @state.game_over  # Check if the game is over
                puts "GAME OVER"
                puts "Puntaje: #{@state.snake.positions.length-2}"  # Display the score, subtracting 2 for the initial length
                break  # Exit the loop if the game is over
            end
            @state = Actions::move_snake(@state)  # Update the game state by moving the snake
            @view.renderGame(@state)  # Render the updated game state
            if snake_length < @state.snake.positions.length  # Check if the snake has grown
                snake_length = @state.snake.positions.length  # Update the snake length variable
                increment_speed  # Increase the game speed
            end
            sleep @speed  # Pause the loop to control game speed
        end
    end

    def send_action(action, params)
        new_state = Actions.send(action, @state, params)  # Send an action to be processed
        if new_state.hash != @state.hash  # Check if the state has changed
            @state = new_state  # Update the state if it has changed
            @view.renderGame(@state)  # Re-render the game view
        end
    end

    private 
    
    def increment_speed
        if @speed > 0.001  # Ensure speed does not become too fast
            @speed = @speed - (@speed * 0.05)  # Reduce speed by 5%
            if @speed < 0.001
                @speed = 0.001  # Set a minimum speed limit
            end
        end     
    end
end

app = App.new
app.start  # Start the game by creating an instance of App and calling start