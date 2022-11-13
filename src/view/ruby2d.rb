require "ruby2d"
require_relative "../model/state"

module View

    class Ruby2dView

        def initialize(app)
            @pixel_size = 50
            @app = app
        end

        def start(state)
            extend Ruby2D::DSL
            set(
                title: "Viper",
                width: @pixel_size * state.grid.columns,
                height: @pixel_size * state.grid.rows)
            on :key_down do |event|
                handle_key_event(event)
            end
            show
        end
        
        def renderGame(state)
            render_snake(state)
            render_food(state)
        end

        private
        
        def render_food(state)
            @food.remove if @food
            extend Ruby2D::DSL
            food = state.food
            @food = Square.new(
                x: food.column * @pixel_size,
                y: food.row * @pixel_size,
                size: @pixel_size,
                color: "white"
            )            
        end

        def render_snake(state)
            @snake_positions.each(&:remove) if @snake_positions
            extend Ruby2D::DSL
            snake = state.snake
            @snake_positions = snake.positions.map do |pos|     
                Square.new(
                    x: pos.column * @pixel_size,
                    y: pos.row * @pixel_size,
                    size: @pixel_size,
                    color: "green"
                )
            end
        end

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