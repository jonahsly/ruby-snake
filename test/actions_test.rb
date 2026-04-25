require "minitest/autorun"
require "minitest/mock"
require_relative "../src/actions/actions"
require_relative "../src/model/state"

class ActionsTest < Minitest::Test
    # Setup method to initialize the state before each test
    def setup
        @initial_state = Model::State.new(
            Model::Snake.new([
                Model::Coord::new(1,1),
                Model::Coord::new(0,1)
            ]),
            Model::Food.new(4,4),
            Model::Grid.new(8,10),
            Model::Direction::DOWN,
            false
        )
    end
    
    # Test to ensure the snake moves correctly
    def test_move_snake
        expected_state = Model::State.new(
            Model::Snake.new([
                Model::Coord.new(2, 1),
                Model::Coord.new(1, 1)
            ]),
            Model::Food.new(4, 4),
            Model::Grid.new(8,10),
            Model::Direction::DOWN,
            false
        )

        actual_state = Actions::move_snake(@initial_state)
        assert_equal actual_state, expected_state, "Snake should move down correctly"
    end

    # Test to ensure that changing direction to an invalid one does not change the state
    def test_change_direction_invalid
        expected_state = @initial_state.dup  # Duplicate initial state to compare after action

        actual_state = Actions::change_direction(@initial_state, Model::Direction::UP)
        assert_equal actual_state, expected_state, "Direction should not change to opposite directly"
    end
    
    # Test to ensure that changing direction to a valid one updates the state correctly
    def test_change_direction_valid
        expected_state = @initial_state.dup
        expected_state.current_direction = Model::Direction::LEFT

        actual_state = Actions::change_direction(@initial_state, Model::Direction::LEFT)
        assert_equal actual_state, expected_state, "Direction should change to left"
    end

    # Test to ensure the snake grows when moving to a cell containing food
    def test_snake_grow
        initial_state = Model::State.new(
            Model::Snake.new([
                Model::Coord.new(1,1),
                Model::Coord.new(0,1)
            ]),
            Model::Food.new(2, 1),
            Model::Grid.new(8,10),
            Model::Direction::DOWN,
            false
        )
        
        actual_state = Actions::move_snake(initial_state)
        assert_equal(actual_state.snake.positions.length, 3, "Snake should grow by one segment")
    end

    # Test to ensure food is generated correctly after eating
    def test_generate_food
        initial_state = Model::State.new(
            Model::Snake.new([
                Model::Coord.new(1,1),
                Model::Coord.new(0,1)
            ]),
            Model::Food.new(2, 1),
            Model::Grid.new(8,10),
            Model::Direction::DOWN,
            false
        )

        Actions.stub(:rand, 0) do
            actual_state = Actions::move_snake(initial_state)
            assert_equal actual_state.food, Model::Food.new(0,0), "Food should be generated at a new position"
        end
    end

    # Test to ensure new food is placed in a free cell when only one is available
    def test_generate_food_uses_only_free_cell
        # 2x3 board where (1,2) is the only available cell after eating.
        initial_state = Model::State.new(
            Model::Snake.new([
                Model::Coord.new(0,1),
                Model::Coord.new(0,0),
                Model::Coord.new(1,0),
                Model::Coord.new(1,1)
            ]),
            Model::Food.new(0,2),
            Model::Grid.new(2,3),
            Model::Direction::RIGHT,
            false
        )

        actual_state = Actions::move_snake(initial_state)
        assert_equal actual_state.food, Model::Food.new(1,2), "Food should spawn in the only free cell"
    end

    # Test to ensure game ends when no free cells remain after eating
    def test_end_game_when_grid_is_full_after_eating
        # 2x2 board that becomes fully occupied right after the next move.
        initial_state = Model::State.new(
            Model::Snake.new([
                Model::Coord.new(0,1),
                Model::Coord.new(0,0),
                Model::Coord.new(1,0)
            ]),
            Model::Food.new(1,1),
            Model::Grid.new(2,2),
            Model::Direction::DOWN,
            false
        )

        actual_state = Actions::move_snake(initial_state)
        assert_equal true, actual_state.game_over, "Game should end when the grid becomes full"
    end

    # Test to ensure game ends when the snake hits the grid boundary
    def test_end_game_on_wall_collision
        # Head starts at row 0 and moves up, which should leave the board.
        initial_state = Model::State.new(
            Model::Snake.new([
                Model::Coord.new(0, 1),
                Model::Coord.new(1, 1)
            ]),
            Model::Food.new(4, 4),
            Model::Grid.new(8, 10),
            Model::Direction::UP,
            false
        )

        actual_state = Actions::move_snake(initial_state)
        assert_equal true, actual_state.game_over, "Game should end after wall collision"
    end

    # Test to ensure game ends when the snake collides with itself
    def test_end_game_on_self_collision
        # Next move to the right lands on an existing body segment.
        initial_state = Model::State.new(
            Model::Snake.new([
                Model::Coord.new(1, 1),
                Model::Coord.new(1, 2),
                Model::Coord.new(2, 2),
                Model::Coord.new(2, 1)
            ]),
            Model::Food.new(4, 4),
            Model::Grid.new(5, 5),
            Model::Direction::RIGHT,
            false
        )

        actual_state = Actions::move_snake(initial_state)
        assert_equal true, actual_state.game_over, "Game should end after self collision"
    end
end
