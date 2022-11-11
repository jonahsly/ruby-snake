require_relative "view/ruby2d"
require_relative "model/state"



class App
    def start
        view = View::Ruby2dView.new
        initial_state = Model::initial_state
        view.render(initial_state)
    end

    def init_timer
        #Loop infinito que desencadena el movimiento de la serpiente
        loop do
            sleep 0.5
            #Trigger movement
            
    end
end