require "minitest/autorun"
require "tmpdir"
require_relative "../src/persistence/high_score_store"

class HighScoreStoreTest < Minitest::Test
  # Uses isolated temporary files so persistence tests are deterministic.
  def with_store_file
    Dir.mktmpdir do |dir|
      file_path = File.join(dir, "high_score.json")
      yield file_path
    end
  end

  def test_load_returns_zero_when_file_is_missing
    with_store_file do |file_path|
      store = Persistence::HighScoreStore.new(file_path: file_path)
      assert_equal 0, store.load
    end
  end

  def test_save_and_load_roundtrip
    with_store_file do |file_path|
      store = Persistence::HighScoreStore.new(file_path: file_path)
      store.save(42)
      assert_equal 42, store.load
    end
  end

  def test_load_returns_zero_when_json_is_invalid
    with_store_file do |file_path|
      File.write(file_path, "not-json")
      store = Persistence::HighScoreStore.new(file_path: file_path)
      assert_equal 0, store.load
    end
  end
end
