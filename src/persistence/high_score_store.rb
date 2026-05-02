require "json"
require "fileutils"

module Persistence
  class HighScoreStore
    DEFAULT_FILE_PATH = File.expand_path("../../.snake_high_score.json", __dir__)

    def initialize(file_path: DEFAULT_FILE_PATH)
      @file_path = file_path
    end

    # Returns persisted high score or zero when file is missing/invalid.
    def load
      return 0 unless File.exist?(@file_path)

      data = JSON.parse(File.read(@file_path))
      value = data["high_score"].to_i
      value.negative? ? 0 : value
    rescue JSON::ParserError, Errno::ENOENT
      0
    end

    # Persists the highest score value using a small JSON payload.
    def save(score)
      normalized_score = [score.to_i, 0].max
      FileUtils.mkdir_p(File.dirname(@file_path))
      payload = { high_score: normalized_score }
      File.write(@file_path, JSON.pretty_generate(payload))
      normalized_score
    end
  end
end
