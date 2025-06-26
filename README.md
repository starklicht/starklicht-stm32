# ✨ Starklicht STM32F410RB Firmware

Welcome to the **Starklicht** firmware repository!  
This project powers creative lighting for **movie makers, theater productions, and professional lighting installations**—where dynamic, reliable, and customizable effects matter most.


---

## 🌟 What is Starklicht?

Starklicht is a modular, STM32-based lighting controller for professional and creative environments.  
It enables **dynamic lighting animations**, **battery management**, and **intuitive user control** for demanding applications.

---

## 🛠️ Hardware Requirements

- STM32F410RB microcontroller board
- USB to UART converter for programming
- Starklicht lighting hardware (LEDs, buttons, display, sensors)

---

## 🚀 Features

- 🎨 **Customizable Lighting Animations:** Create and control stunning effects for any scene.
- 🔋 **Battery Management:** Real-time monitoring and smart power handling.
- 🖥️ **User Interface:** Graphical display and button input for easy, on-the-fly adjustments.
- 💾 **EEPROM Support:** Save and recall your favorite effects and settings.
- 🧩 **Modular C++ Design:** Clean, maintainable codebase with reusable classes.

---

## 🧩 Software Architecture

![Editor _ Mermaid Chart-2025-06-26-141957](https://github.com/user-attachments/assets/013f5e74-1aa0-4c84-959f-d2c3d1c1fc6c)


- **Main Application:** Entry point (`main.c`, `starklicht.cpp`)
- **Controller:** Central logic and coordination
- **Display:** Handles graphical output (u8g2 library)
- **Animation:** Manages lighting effects
- **Battery:** Monitors and manages power
- **Messaging:** Communication and event handling over BLE

---

## 🏁 Getting Started

### Prerequisites

- [STM32CubeIDE](https://www.st.com/en/development-tools/stm32cubeide.html)
- [STM32CubeProgrammer](https://www.st.com/en/development-tools/stm32cubeprog.html)
- CMake or Make (optional, for advanced builds)

### Setup

1. Clone this repository:
   ```sh
   git clone https://github.com/yourusername/starklicht-stm32.git
   ```
2. Open the project in STM32CubeIDE.
3. Configure your project settings for the STM32F410RB.
4. Connect your hardware as described above.

### Building and Flashing

1. Build the project in STM32CubeIDE.
2. Connect the STM32F410RB board via USB to UART.
3. Use STM32CubeProgrammer to flash the firmware onto the MCU.

---

## 🎬 Example Use Cases

- 🎥 **Movie Sets:** Sync lighting with camera cues for dramatic effects.
- 🎭 **Theater:** Dynamic scene changes and mood lighting.
- 💡 **Installations:** Interactive or automated light shows.

---

## 🤝 Contributing

We welcome your ideas and improvements!  
See `CONTRIBUTING.md` for guidelines.

---

## 📄 License

GLP3.0 – see [LICENSE](LICENSE) for details.

---

## 📬 Contact

Questions or support?  
Email us: [kontakt@starklicht.net](mailto:kontakt@starklicht.net)
