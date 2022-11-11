module Actions #Realiza las acciones consecutivas a cada evento (avanzar, girar)
    #Estos métodos reciben el estado actual y retornan el nuevo estado
    def self.move_snake(state) 
        next_direction = state.next_direction
        next_position = calc_next_position(state)
        #Verificamos que la sig. casilla sea válida para terminar o continuar el juego
        if position_is_valid?(state, next_position)
            move_snake_to(state, next_position)
        else
            end_game(state)
        end
    end

    private

    def self.calc_next_position(state)
        current_position = state.snake.positions.first
        case state.next_direction
        when Model::Direction::LEFT 
            #decrementar fila
            #[(1,1),(0,1)]
            return Model::Coord.new(current_position.row - 1, current_position.column)
        when Model::Direction::RIGHT
            #incrementar columna
            return Model::Coord.new(current_position.row, current_position.column + 1)

        when Model::Direction::UP
            #incrementar fila
            return Model::Coord.new(current_position.row + 1, current_position.column)

        when Model::Direction::DOWN 
            #decrementar columna
            return Model::Coord.new(
                current_position.row,
                current_position.column - 1)
        end
    end
    #Verifica si la siguiente posicion es válida
    def self.position_is_valid?(state, position)
        #Verificar que estè en la grilla
        is_invalid = ((position.row >= state.grid.rows ||
            position.row > 0) ||
            (position.column >= state.grid.columns ||
            position.column > 0))
        return false if is_invalid
        #Verificar que no esté superponiendo a la serpiente
        return !(state.snake.positions.include? position)  
    end

    def self.move_snake_to(state, next_position)
        #Posición inicial
        #[(1,1)(1,0)]
        #Simulamos la rotacion del arreglo de la serpiente
        new_positions = [new_position] + state.snake.positions[0...-1]
        #Modificamos el estado
        state.snake.positions = new_positions
        state
    end

    def self.end_game(state)
        state.game_over = true
        state
    end
end