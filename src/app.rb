require_relative "view/ruby2d"  # Load the Ruby2D view script
require_relative "model/state"  # Load the game state model
require_relative "actions/actions"  # Load the actions script which contains game logic
require_relative "config/game_config"  # Load difficulty and tuning values

class App

    MAX_FRAME_DELTA_SECONDS = 0.25
    MAX_STEPS_PER_FRAME = 5

    def initialize(config = Config::GameConfig.build_from_env)
        @config = config
        reset_game_state
        @running = false  # Controls timer loop lifecycle
        @mode = :start_screen
        @high_score = 0
    end

    def start
        @view = View::Ruby2dView.new(self)  # Create a new view object for the game
        @running = true
        @view.start(@state, @mode, hud_data)  # Start the game view
    ensure
        # Ensure the app state is closed when the window loop exits.
        request_stop
    end

    # Drives one Ruby2D update frame from the window loop.
    def tick
        return unless @running
        update_frame_timing

        if @mode == :running
            simulated_steps = 0

            # Run fixed simulation steps while enough frame time is accumulated.
            while @step_accumulator >= @speed && simulated_steps < MAX_STEPS_PER_FRAME && @mode == :running
                run_simulation_step
                @step_accumulator -= @speed
                simulated_steps += 1
            end
        end

        @view.render_frame(@state, @mode, hud_data)
    end

    def send_action(action, params)
        return unless @running && @mode == :running
        return if action == :change_direction && @direction_changed_this_tick

        new_state = Actions.send(action, @state, params)  # Send an action to be processed
        if new_state.hash != @state.hash  # Check if the state has changed
            @state = new_state  # Update the state if it has changed
            # Allow only one accepted turn between movement ticks.
            @direction_changed_this_tick = true if action == :change_direction
            @view.render_frame(@state, @mode, hud_data)  # Re-render the game view
        end
    end

    # Starts gameplay from the start screen.
    def start_game
        return unless @mode == :start_screen

        @mode = :running
        reset_timing_state
        @view.render_frame(@state, @mode, hud_data)
    end

    # Pauses or resumes gameplay while keeping the current board state.
    def toggle_pause
        return unless [:running, :paused].include?(@mode)

        @mode = (@mode == :running ? :paused : :running)
        reset_timing_state if @mode == :running
        @view.render_frame(@state, @mode, hud_data)
    end

    # Restarts the round and immediately enters running mode.
    def restart_game
        return unless [:game_over, :running, :paused].include?(@mode)

        reset_game_state
        @mode = :running
        @view.render_frame(@state, @mode, hud_data)
    end

    # Called by the view when the player closes the window or requests quit.
    def request_stop
        @running = false
    end

    # Exposes static runtime config to the view layer.
    def config
        @config
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
            speed: @speed,
            difficulty: @config.name
        }
    end

    def reset_game_state
        @state = Model::initial_state(@config)
        @speed = @config.initial_speed_tick
        # Keep growth tracking in sync after every fresh round.
        @tracked_snake_length = @state.snake.positions.length
        @direction_changed_this_tick = false
        reset_timing_state
    end

    def update_high_score
        @high_score = [@high_score, score].max
    end

    def run_simulation_step
        @state = Actions::move_snake(@state)  # Update the game state by moving the snake
        if @state.game_over
            puts "GAME OVER"
            puts "Puntaje: #{score}"
            update_high_score
            @mode = :game_over
            return
        end

        if @tracked_snake_length < @state.snake.positions.length  # Check if the snake has grown
            @tracked_snake_length = @state.snake.positions.length  # Update the snake length tracker
            increment_speed  # Increase the game speed
        end

        # Unlock one direction change for the next simulation tick.
        @direction_changed_this_tick = false
    end

    # Tracks real elapsed time between frames and caps spikes after stalls.
    def update_frame_timing
        now = monotonic_now
        elapsed = now - @last_frame_at
        @last_frame_at = now
        @step_accumulator += [elapsed, MAX_FRAME_DELTA_SECONDS].min
    end

    def reset_timing_state
        @last_frame_at = monotonic_now
        @step_accumulator = 0.0
    end

    # Uses monotonic time so gameplay speed is stable across system clock changes.
    def monotonic_now
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
    
    def increment_speed
        return unless @speed > @config.min_speed_tick

        # Reduce delay progressively using configured acceleration.
        @speed -= (@speed * @config.speed_acceleration_rate)
        @speed = @config.min_speed_tick if @speed < @config.min_speed_tick
    end
end

app = App.new
app.start  # Start the game by creating an instance of App and calling start
