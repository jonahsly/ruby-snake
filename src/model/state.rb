module Model

    module Direction
        LEFT = :left
        RIGHT = :right
        UP = :up
        DOWN = :down
    end

    class Coord < Struct.new(:row, :column)
    end
    
    class Food < Coord
    end
    
    class Snake < Struct.new(:positions)
    end
    
    class Grid < Struct.new(:rows, :columns)
    end

    class State < Struct.new(:snake, :food, :grid, :current_direction, :game_over)
    end

    def self.initial_state
        Model::State.new(
            Model::Snake.new([
                Model::Coord.new(1, 1),
                Model::Coord.new(0, 1)
            ]),
            Model::Food.new(4, 4),
            Model::Grid.new(8,10),
            Direction::DOWN,
            false
        )
    end
end