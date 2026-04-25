# Ruby Snake

A simple implementation of the classic Snake game built with Ruby and Ruby2D.

## Table of Contents
- [English](#english)
- [Espanol](#espanol)

## English

### Overview
`ruby-snake` is a lightweight desktop version of Snake. The game renders a grid with Ruby2D, moves the snake automatically, increases speed as you grow, and ends on wall or self collision.

### Features
- Grid-based Snake gameplay.
- Keyboard direction control (`Up`, `Down`, `Left`, `Right`).
- Food spawning and snake growth.
- Progressive speed increase as the snake gets longer.
- Basic automated tests for game actions.

### Tech Stack
- Ruby
- Ruby2D
- Minitest

### Requirements
- Ruby 2.7+
- Bundler

### Installation
1. Clone the repository:
```bash
git clone https://github.com/<your-user>/ruby-snake.git
cd ruby-snake
```
2. Install dependencies:
```bash
bundle install
```

### Run the Game
```bash
bundle exec ruby src/app.rb
```

### Controls
- `Up Arrow`: Move up
- `Down Arrow`: Move down
- `Left Arrow`: Move left
- `Right Arrow`: Move right

### Run Tests
```bash
bundle exec ruby test/actions_test.rb
```

### Project Structure
- `src/app.rb`: Application entry point and game loop.
- `src/model/state.rb`: Domain model and initial game state.
- `src/actions/actions.rb`: Movement and game rules.
- `src/view/ruby2d.rb`: Rendering and keyboard input.
- `test/actions_test.rb`: Unit tests for action logic.

### License
This project is licensed under the MIT License. See `LICENSE` for details.

---

## Espanol

### Descripcion General
`ruby-snake` es una version de escritorio simple del juego clasico Snake. El juego se renderiza en una grilla con Ruby2D, mueve la serpiente automaticamente, aumenta la velocidad al crecer y termina al chocar contra una pared o contra si misma.

### Funcionalidades
- Jugabilidad de Snake basada en grilla.
- Control de direccion con teclado (`Arriba`, `Abajo`, `Izquierda`, `Derecha`).
- Aparicion de comida y crecimiento de la serpiente.
- Aumento progresivo de velocidad a medida que crece.
- Pruebas automaticas basicas para las acciones del juego.

### Stack Tecnologico
- Ruby
- Ruby2D
- Minitest

### Requisitos
- Ruby 2.7+
- Bundler

### Instalacion
1. Clona el repositorio:
```bash
git clone https://github.com/<tu-usuario>/ruby-snake.git
cd ruby-snake
```
2. Instala las dependencias:
```bash
bundle install
```

### Ejecutar el Juego
```bash
bundle exec ruby src/app.rb
```

### Controles
- `Flecha Arriba`: Mover arriba
- `Flecha Abajo`: Mover abajo
- `Flecha Izquierda`: Mover a la izquierda
- `Flecha Derecha`: Mover a la derecha

### Ejecutar Pruebas
```bash
bundle exec ruby test/actions_test.rb
```

### Estructura del Proyecto
- `src/app.rb`: Punto de entrada y bucle principal del juego.
- `src/model/state.rb`: Modelo de dominio y estado inicial.
- `src/actions/actions.rb`: Movimiento y reglas del juego.
- `src/view/ruby2d.rb`: Renderizado y entrada de teclado.
- `test/actions_test.rb`: Pruebas unitarias de la logica de acciones.

### Licencia
Este proyecto esta licenciado bajo la licencia MIT. Revisa `LICENSE` para mas detalles.
