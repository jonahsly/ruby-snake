require "ruby2d"
require_relative "../model/state"

module View

    class Ruby2dView

        # Initializes the view with the application instance and sets the pixel size for rendering
        def initialize(app)
            @pixel_size = 50
            @app = app
        end

        # Starts the Ruby2D window and game loop
        def start(state)
            extend Ruby2D::DSL
            set(
                title: "Viper",  # Window title
                width: @pixel_size * state.grid.columns,  # Window width based on grid size
                height: @pixel_size * state.grid.rows    # Window height based on grid size
            )
            on :key_down do |event|
                handle_key_event(event)  # Handles key press events
            end
            show  # Displays the window
        end
        
        # Renders the game state, updating the positions of the snake and food
        def renderGame(state)
            extend Ruby2D::DSL
            close if state.game_over  # Closes the window if the game is over
            render_snake(state)  # Renders the snake on the grid
            render_food(state)  # Renders the food on the grid
        end

        private
        
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
            end
        end
    end
end