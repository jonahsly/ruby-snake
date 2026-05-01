require "minitest/autorun"
require_relative "../src/model/state"
require_relative "../src/config/game_config"

class ModelStateTest < Minitest::Test
  # Ensures initial_state consumes configured grid dimensions.
  def test_initial_state_uses_configured_grid
    config = Config::GameConfig::DIFFICULTIES["hard"]

    state = Model.initial_state(config)

    assert_equal 10, state.grid.rows
    assert_equal 14, state.grid.columns
  end
end
