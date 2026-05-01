require "minitest/autorun"
require_relative "../src/runtime/game_loop"

class RuntimeGameLoopTest < Minitest::Test
  # Verifies fixed-step scheduling with deterministic clock progression.
  def test_steps_due_for_accumulated_time
    time = 0.0
    loop_runtime = Runtime::GameLoop.new(
      step_interval_seconds: 0.1,
      clock: -> { time }
    )

    time = 0.09
    assert_equal 0, loop_runtime.steps_due

    time = 0.21
    assert_equal 2, loop_runtime.steps_due
  end

  # Ensures very large frame deltas are bounded by per-frame safeguards.
  def test_steps_due_respects_max_steps_per_frame
    time = 0.0
    loop_runtime = Runtime::GameLoop.new(
      step_interval_seconds: 0.02,
      max_steps_per_frame: 3,
      max_frame_delta_seconds: 1.0,
      clock: -> { time }
    )

    time = 1.0
    assert_equal 3, loop_runtime.steps_due
  end
end
