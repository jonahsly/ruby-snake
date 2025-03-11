module Model

    # Module to define directions for snake movement
    module Direction
        LEFT = :left   # Represents left direction
        RIGHT = :right # Represents right direction
        UP = :up       # Represents upward direction
        DOWN = :down   # Represents downward direction
    end

    # Class representing a coordinate on the grid
    class Coord < Struct.new(:row, :column)
        # Inherits from Struct to automatically create getter and setter methods for row and column
    end
    
    # Class representing food on the grid, inherits from Coord
    class Food < Coord
        # Uses Coord structure to represent its position
    end
    
    # Class representing the snake, which is a series of positions (coordinates)
    class Snake < Struct.new(:positions)
        # Inherits from Struct to manage an array of positions that represent the snake's body
    end
    
    # Class representing the grid on which the game is played
    class Grid < Struct.new(:rows, :columns)
        # Inherits from Struct to automatically create getter and setter methods for rows and columns
    end

    # Class representing the overall state of the game
    class State < Struct.new(:snake, :food, :grid, :current_direction, :game_over)
        # Inherits from Struct to manage game state including snake, food, grid, current direction, and game status
    end

    # Method to initialize the game state with default values
    def self.initial_state
        Model::State.new(
            Model::Snake.new([
                Model::Coord.new(1, 1),  # Starting position of the snake's head
                Model::Coord.new(0, 1)   # Starting position of the snake's second segment
            ]),
            Model::Food.new(4, 4),      # Initial position of the food
            Model::Grid.new(8, 10),     # Size of the grid
            Direction::DOWN,            # Initial movement direction of the snake
            false                       # Game over flag set to false initially
        )
    end
end