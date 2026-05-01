require_relative "../model/state"

module Controllers
  class InputController
    def initialize(app)
      @app = app
    end

    # Maps keyboard input to game actions and app state transitions.
    def handle_key(key)
      case key
      when "up"
        @app.send_action(:change_direction, Model::Direction::UP)
      when "down"
        @app.send_action(:change_direction, Model::Direction::DOWN)
      when "left"
        @app.send_action(:change_direction, Model::Direction::LEFT)
      when "right"
        @app.send_action(:change_direction, Model::Direction::RIGHT)
      when "return"
        @app.start_game
      when "p"
        @app.toggle_pause
      when "r"
        @app.restart_game
      when "escape", "q"
        @app.request_stop
        @app.close_window
      end
    end
  end
end
