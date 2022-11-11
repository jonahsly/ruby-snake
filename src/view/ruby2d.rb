require "ruby2d"

module View
    class Ruby2dView

        def initialize
            #square size
            @pixel_size = 50
        end
        #Método que recibe los datos de la app para colorearla
        def render(state)
            extend Ruby2D::DSL
            set(
                title: "Snake",
                width: @pixel_size*state.grid.columns,
                height: @pixel_size*state.grid.rows
            )
            render_snake(state)
            render_food(state)
            show
        end

        private #Funciones solo accesibles desde esta clase

        def render_snake(state)
            
        end

        def render_food(state)
            extend Ruby2D::DSL
            food = state.food
            Square.new(
                x: food.column * @pixel_size,
                y: food.row * @pixel_size,
                size: @pixel_size,
                color: "white",
            )            
        end
    end
end

