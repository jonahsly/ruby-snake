module Runtime
  class GameLoop
    DEFAULT_MAX_FRAME_DELTA_SECONDS = 0.25

    def initialize(step_interval_seconds:, max_steps_per_frame: 5, max_frame_delta_seconds: DEFAULT_MAX_FRAME_DELTA_SECONDS, clock: nil)
      @step_interval_seconds = step_interval_seconds
      @max_steps_per_frame = max_steps_per_frame
      @max_frame_delta_seconds = max_frame_delta_seconds
      # Allow clock injection for deterministic tests.
      @clock = clock || -> { Process.clock_gettime(Process::CLOCK_MONOTONIC) }
      reset
    end

    # Resets accumulated frame time after pause/restart transitions.
    def reset
      @last_frame_at = @clock.call
      @step_accumulator = 0.0
    end

    def step_interval_seconds=(value)
      @step_interval_seconds = value
    end

    # Returns how many fixed simulation steps should run on this frame.
    def steps_due
      now = @clock.call
      elapsed = now - @last_frame_at
      @last_frame_at = now
      @step_accumulator += [elapsed, @max_frame_delta_seconds].min

      steps = 0
      while @step_accumulator >= @step_interval_seconds && steps < @max_steps_per_frame
        @step_accumulator -= @step_interval_seconds
        steps += 1
      end

      steps
    end
  end
end
