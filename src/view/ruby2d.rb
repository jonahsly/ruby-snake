require "ruby2d"
require_relative "../model/state"
require_relative "../controllers/input_controller"

module View

    class Ruby2dView

        THEME = {
            board_running: "#0e1a2b",
            board_paused: "#1f2937",
            board_start: "#0f2b24",
            board_game_over: "#2b1111",
            overlay_panel: "#0b1220",
            overlay_title: "#f8fafc",
            overlay_body: "#d1d5db",
            hud_text: "#e2e8f0",
            snake_head: "#7dd3fc",
            snake_body: "#22c55e",
            food: "#fb7185",
            frame: "#334155"
        }.freeze

        # Initializes the view with the application instance and sets the pixel size for rendering
        def initialize(app)
            # Pixel size is driven by selected difficulty to keep board readable.
            @pixel_size = app.config.pixel_size
            @app = app
            @input_controller = Controllers::InputController.new(app)
            @status_labels = []
            @hud_labels = []
            @status_mode = nil
        end

        # Starts the Ruby2D window and game loop
        def start(state, mode, hud_data)
            extend Ruby2D::DSL
            @window_width = @pixel_size * state.grid.columns
            @window_height = @pixel_size * state.grid.rows
            set(
                title: "Viper",  # Window title
                width: @window_width,  # Window width based on grid size
                height: @window_height    # Window height based on grid size
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
            render_background(mode)
            render_grid_frame
            render_snake(state)  # Renders the snake on the grid
            render_food(state)  # Renders the food on the grid
            render_hud(hud_data)
            render_status(mode, hud_data)
        end

        # Exposes a dedicated close operation for controllers and app state transitions.
        def close_window
            extend Ruby2D::DSL
            close
        end

        private

        # Applies a contextual board color and subtle animated vignette.
        def render_background(mode)
            color = case mode
                    when :paused
                        THEME[:board_paused]
                    when :start_screen
                        THEME[:board_start]
                    when :game_over
                        THEME[:board_game_over]
                    else
                        THEME[:board_running]
                    end

            unless @background
                @background = Rectangle.new(
                    x: 0,
                    y: 0,
                    width: @window_width,
                    height: @window_height,
                    color: color,
                    z: -30
                )
                @vignette = Rectangle.new(
                    x: 0,
                    y: 0,
                    width: @window_width,
                    height: @window_height,
                    color: "black",
                    z: -29,
                    opacity: 0.18
                )
            end

            @background.color = color
            pulse = 0.14 + ((Math.sin(monotonic_now * 2.2) + 1.0) * 0.04)
            @vignette.color.opacity = pulse
        end

        # Draws a static frame around the board to define gameplay boundaries.
        def render_grid_frame
            return if @grid_frame

            @grid_frame = Rectangle.new(
                x: 1,
                y: 1,
                width: @window_width - 2,
                height: @window_height - 2,
                color: THEME[:frame],
                z: -5
            )
            @grid_frame.color.opacity = 0.25
        end

        # Displays score, high score and speed on every frame.
        def render_hud(hud_data)
            unless @hud_panel
                @hud_panel = Rectangle.new(
                    x: 8,
                    y: 8,
                    width: 230,
                    height: 92,
                    color: THEME[:overlay_panel],
                    z: 10,
                    opacity: 0.72
                )
            end

            if @hud_labels.empty?
                @hud_labels << Text.new("", x: 16, y: 14, size: 16, color: THEME[:hud_text], z: 11)
                @hud_labels << Text.new("", x: 16, y: 34, size: 16, color: THEME[:hud_text], z: 11)
                @hud_labels << Text.new("", x: 16, y: 54, size: 16, color: THEME[:hud_text], z: 11)
                @hud_labels << Text.new("", x: 16, y: 74, size: 16, color: THEME[:hud_text], z: 11)
            end

            @hud_labels[0].text = "Score: #{hud_data[:score]}"
            @hud_labels[1].text = "High: #{hud_data[:high_score]}"
            @hud_labels[2].text = format("Speed: %.3fs", hud_data[:speed])
            @hud_labels[3].text = "Difficulty: #{hud_data[:difficulty]}"
        end

        # Rebuilds text overlays to keep the current mode visible to the player.
        def render_status(mode, hud_data)
            if mode == :running
                clear_status_overlay
                return
            end

            title_text, body_text = status_messages(mode, hud_data)
            if @status_mode != mode || @status_labels.empty?
                clear_status_overlay
                @status_panel = Rectangle.new(
                    x: 14,
                    y: 10,
                    width: @window_width - 28,
                    height: 90,
                    color: THEME[:overlay_panel],
                    z: 15,
                    opacity: 0.78
                )
                @status_labels << Text.new(title_text, x: 24, y: 22, size: 28, color: THEME[:overlay_title], z: 16)
                @status_labels << Text.new(body_text, x: 24, y: 58, size: 18, color: THEME[:overlay_body], z: 16)
                @status_mode = mode
            else
                @status_labels[0].text = title_text
                @status_labels[1].text = body_text
            end

            # Animate overlay opacity so instructions stay noticeable without being noisy.
            animated_opacity = 0.72 + ((Math.sin(monotonic_now * 3.2) + 1.0) * 0.08)
            @status_panel.color.opacity = animated_opacity if @status_panel
        end

        def clear_status_overlay
            @status_panel&.remove
            @status_panel = nil
            @status_labels.each(&:remove)
            @status_labels = []
            @status_mode = nil
        end

        # Builds contextual title/body copy for state transitions and retry guidance.
        def status_messages(mode, hud_data)
            case mode
            when :start_screen
                ["READY TO PLAY", "Press Enter to start  |  P pause  |  R restart  |  Esc/Q quit"]
            when :paused
                ["PAUSED", "Press P to resume  |  R restart  |  Esc/Q quit"]
            when :game_over
                title = "GAME OVER - Score: #{hud_data[:score]}"
                body = "Best: #{hud_data[:high_score]}  |  Press R to retry  |  Esc/Q quit"
                [title, body]
            else
                ["", ""]
            end
        end
        
        # Renders the food at its current position
        def render_food(state)
            extend Ruby2D::DSL
            food = state.food
            unless @food
                @food = Square.new(
                    x: 0,
                    y: 0,
                    z: -1,
                    size: @pixel_size,
                    color: THEME[:food]
                )
            end

            # Reuse the existing shape to avoid per-frame allocation churn.
            @food.x = food.column * @pixel_size
            @food.y = food.row * @pixel_size
        end

        # Renders the snake at its current positions
        def render_snake(state)
            extend Ruby2D::DSL
            snake = state.snake
            @snake_positions ||= []

            while @snake_positions.length < snake.positions.length
                # Grow the render pool only when the snake actually grows.
                @snake_positions << Square.new(
                    x: 0,
                    y: 0,
                    size: @pixel_size,
                    color: THEME[:snake_body]
                )
            end

            while @snake_positions.length > snake.positions.length
                @snake_positions.pop.remove
            end

            snake.positions.each_with_index do |pos, index|
                square = @snake_positions[index]
                square.x = pos.column * @pixel_size
                square.y = pos.row * @pixel_size
                square.color = index.zero? ? THEME[:snake_head] : THEME[:snake_body]
            end
        end

        # Handles key press events to change the direction of the snake
        def handle_key_event(event)
            @input_controller.handle_key(event.key)
        end

        # Uses monotonic time for stable animation regardless of system clock changes.
        def monotonic_now
            Process.clock_gettime(Process::CLOCK_MONOTONIC)
        end
    end
end
