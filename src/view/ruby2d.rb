require "ruby2d"
require_relative "../model/state"

module View

    class Ruby2dView

        # Initializes the view with the application instance and sets the pixel size for rendering
        def initialize(app)
            # Pixel size is driven by selected difficulty to keep board readable.
            @pixel_size = app.config.pixel_size
            @app = app
            @status_labels = []
            @hud_labels = []
        end

        # Starts the Ruby2D window and game loop
        def start(state, mode, hud_data)
            extend Ruby2D::DSL
            set(
                title: "Viper",  # Window title
                width: @pixel_size * state.grid.columns,  # Window width based on grid size
                height: @pixel_size * state.grid.rows    # Window height based on grid size
            )
            on :key_down do |event|
                handle_key_event(event)  # Handles key press events
            end
            # Keep game updates in Ruby2D's main loop to avoid orphan background threads.
            update do
                @app.tick
            end
            render_frame(state, mode, hud_data)
            show  # Displays the window
            # Notify the app loop after any window close path.
            @app.request_stop
        end
        
        # Renders the game state, updating the positions of the snake and food
        def render_frame(state, mode, hud_data)
            extend Ruby2D::DSL
            render_snake(state)  # Renders the snake on the grid
            render_food(state)  # Renders the food on the grid
            render_hud(hud_data)
            render_status(mode, hud_data[:score])
        end

        private

        # Displays score, high score and speed on every frame.
        def render_hud(hud_data)
            @hud_labels.each(&:remove)
            @hud_labels = []

            @hud_labels << Text.new(
                "Score: #{hud_data[:score]}",
                x: 10,
                y: 8,
                size: 16,
                color: "white",
                z: 10
            )
            @hud_labels << Text.new(
                "High: #{hud_data[:high_score]}",
                x: 10,
                y: 28,
                size: 16,
                color: "white",
                z: 10
            )
            @hud_labels << Text.new(
                format("Speed: %.3fs", hud_data[:speed]),
                x: 10,
                y: 48,
                size: 16,
                color: "white",
                z: 10
            )
            @hud_labels << Text.new(
                "Difficulty: #{hud_data[:difficulty]}",
                x: 10,
                y: 68,
                size: 16,
                color: "white",
                z: 10
            )
        end

        # Rebuilds text overlays to keep the current mode visible to the player.
        def render_status(mode, score)
            @status_labels.each(&:remove)
            @status_labels = []

            case mode
            when :start_screen
                @status_labels << Text.new(
                    "Press Enter to Start",
                    x: 18,
                    y: 12,
                    size: 28,
                    color: "yellow"
                )
                @status_labels << Text.new(
                    "P: Pause  R: Restart  Esc/Q: Quit",
                    x: 18,
                    y: 48,
                    size: 18,
                    color: "white"
                )
            when :paused
                @status_labels << Text.new(
                    "PAUSED - Press P to Resume",
                    x: 18,
                    y: 12,
                    size: 26,
                    color: "orange"
                )
                @status_labels << Text.new(
                    "R: Restart  Esc/Q: Quit",
                    x: 18,
                    y: 48,
                    size: 18,
                    color: "white"
                )
            when :game_over
                @status_labels << Text.new(
                    "GAME OVER - Score: #{score}",
                    x: 18,
                    y: 12,
                    size: 28,
                    color: "red"
                )
                @status_labels << Text.new(
                    "Press R to Restart or Esc/Q to Quit",
                    x: 18,
                    y: 48,
                    size: 18,
                    color: "white"
                )
            end
        end
        
        # Renders the food at its current position
        def render_food(state)
            @food.remove if @food  # Removes the old food square if it exists
            extend Ruby2D::DSL
            food = state.food
            @food = Square.new(
                x: food.column * @pixel_size,  # X position based on grid column
                y: food.row * @pixel_size,    # Y position based on grid row
                z: -1,  # Z index for layering
                size: @pixel_size,
                color: "white"
            )            
        end

        # Renders the snake at its current positions
        def render_snake(state)
            @snake_positions.each(&:remove) if @snake_positions  # Removes old snake squares
            extend Ruby2D::DSL
            snake = state.snake
            @snake_positions = snake.positions.map do |pos|     
                Square.new(
                    x: pos.column * @pixel_size,  # X position based on grid column
                    y: pos.row * @pixel_size,    # Y position based on grid row
                    size: @pixel_size,
                    color: "green"
                )
            end
        end

        # Handles key press events to change the direction of the snake
        def handle_key_event(event)
            case event.key
            when "up"
                @app.send_action(:change_direction, Model::Direction::UP)
            when "down"
                @app.send_action(:change_direction, Model::Direction::DOWN)
            when "left"
                @app.send_action(:change_direction, Model::Direction::LEFT)
            when "right"
                @app.send_action(:change_direction, Model::Direction::RIGHT)
            when "return"
                # Starts the game from the start screen.
                @app.start_game
            when "p"
                # Toggles pause/resume only for active gameplay.
                @app.toggle_pause
            when "r"
                # Restarts the round from game over, paused, or running states.
                @app.restart_game
            when "escape", "q"
                # Fast quit path to avoid leaving a running process in terminal.
                @app.request_stop
                close
            end
        end
    end
end
