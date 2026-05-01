module Config
  # Stores tuning values per difficulty level.
  Difficulty = Struct.new(
    :name,
    :grid_rows,
    :grid_columns,
    :pixel_size,
    :initial_speed_tick,
    :speed_acceleration_rate,
    :min_speed_tick,
    keyword_init: true
  )

  module GameConfig
    DIFFICULTIES = {
      "easy" => Difficulty.new(
        name: "easy",
        grid_rows: 8,
        grid_columns: 10,
        pixel_size: 50,
        initial_speed_tick: 0.55,
        speed_acceleration_rate: 0.04,
        min_speed_tick: 0.06
      ),
      "normal" => Difficulty.new(
        name: "normal",
        grid_rows: 8,
        grid_columns: 10,
        pixel_size: 50,
        initial_speed_tick: 0.50,
        speed_acceleration_rate: 0.05,
        min_speed_tick: 0.04
      ),
      "hard" => Difficulty.new(
        name: "hard",
        grid_rows: 10,
        grid_columns: 14,
        pixel_size: 42,
        initial_speed_tick: 0.38,
        speed_acceleration_rate: 0.06,
        min_speed_tick: 0.03
      )
    }.freeze

    module_function

    # Reads difficulty from env and falls back to normal if value is invalid.
    def build_from_env
      level = ENV.fetch("SNAKE_DIFFICULTY", "normal").downcase
      DIFFICULTIES.fetch(level, DIFFICULTIES["normal"])
    end
  end
end
