require_relative "view/ruby2d"  # Load the Ruby2D view script
require_relative "model/state"  # Load the game state model
require_relative "actions/actions"  # Load the actions script which contains game logic

class App

    INITIAL_SPEED = 0.5

    def initialize
        reset_game_state
        @running = false  # Controls timer loop lifecycle
        @mode = :start_screen
        @high_score = 0
    end

    def start
        @view = View::Ruby2dView.new(self)  # Create a new view object for the game
        @running = true
        timer_thread = Thread.new { init_timer }  # Start a new thread to handle game timing
        @view.start(@state, @mode, hud_data)  # Start the game view
    ensure
        # Ensure the process can always return to shell if the window closes unexpectedly.
        request_stop
        timer_thread.join(1) if timer_thread
        timer_thread.kill if timer_thread&.alive?
    end

    def init_timer
        while @running
            if @mode == :running
                @state = Actions::move_snake(@state)  # Update the game state by moving the snake
                if @state.game_over
                    puts "GAME OVER"
                    puts "Puntaje: #{score}"
                    update_high_score
                    @mode = :game_over
                end
                if @tracked_snake_length < @state.snake.positions.length  # Check if the snake has grown
                    @tracked_snake_length = @state.snake.positions.length  # Update the snake length tracker
                    increment_speed  # Increase the game speed
                end
                # Unlock one direction change for the next simulation tick.
                @direction_changed_this_tick = false
            end
            @view.render(@state, @mode, hud_data)
            sleep(@mode == :running ? @speed : 0.05)
        end
    end

    def send_action(action, params)
        return unless @running && @mode == :running
        return if action == :change_direction && @direction_changed_this_tick

        new_state = Actions.send(action, @state, params)  # Send an action to be processed
        if new_state.hash != @state.hash  # Check if the state has changed
            @state = new_state  # Update the state if it has changed
            # Allow only one accepted turn between movement ticks.
            @direction_changed_this_tick = true if action == :change_direction
            @view.render(@state, @mode, hud_data)  # Re-render the game view
        end
    end

    # Starts gameplay from the start screen.
    def start_game
        return unless @mode == :start_screen

        @mode = :running
        @view.render(@state, @mode, hud_data)
    end

    # Pauses or resumes gameplay while keeping the current board state.
    def toggle_pause
        return unless [:running, :paused].include?(@mode)

        @mode = (@mode == :running ? :paused : :running)
        @view.render(@state, @mode, hud_data)
    end

    # Restarts the round and immediately enters running mode.
    def restart_game
        return unless [:game_over, :running, :paused].include?(@mode)

        reset_game_state
        @mode = :running
        @view.render(@state, @mode, hud_data)
    end

    # Called by the view when the player closes the window or requests quit.
    def request_stop
        @running = false
    end

    private 

    def score
        @state.snake.positions.length - 2
    end

    # Collects HUD metrics shown in the game window.
    def hud_data
        {
            score: score,
            high_score: @high_score,
            speed: @speed
        }
    end

    def reset_game_state
        @state = Model::initial_state
        @speed = INITIAL_SPEED
        # Keep growth tracking in sync after every fresh round.
        @tracked_snake_length = @state.snake.positions.length
        @direction_changed_this_tick = false
    end

    def update_high_score
        @high_score = [@high_score, score].max
    end
    
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
