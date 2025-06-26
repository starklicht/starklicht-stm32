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
- HM10 BLE Module for Bluetooth connectivity
- RGB Led Chip of your choice (we are using LED COB 100W RGB ML-56 COB (JX-SPEC-WW-0100))

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
## ✉️ Messaging Protocol

### Design Philosophy

The Starklicht BLE protocol is designed for maximum efficiency and simplicity, tailored for the constraints of Bluetooth Low Energy and embedded microcontrollers.

*   **Lightweight:** We use a raw binary format instead of text (like JSON). This makes messages extremely compact, ensuring most commands fit within a single 20-byte BLE packet to reduce latency and power consumption.
*   **Fast to Parse:** The fixed `[ID][DATA]` structure allows the device's firmware to read values directly from memory offsets without needing a complex parser, saving precious CPU cycles and RAM.
*   **Embedded-Friendly:** The protocol uses integer math where possible to avoid computationally expensive floating-point operations on the microcontroller.

This protocol is a living document. We are open to suggestions and changes to improve its functionality and performance.

---

### Message API Reference

All multi-byte values are encoded in **Big Endian** format.

#### **1. Color Message (ID: `0`)**
Sets a solid color.

| Byte | Field | Description |
| :--- | :---- | :--- |
| 0 | ID | `0` |
| 1 | Red | Red channel (0-255) |
| 2 | Green | Green channel (0-255) |
| 3 | Blue | Blue channel (0-255) |

*   **Example (Set color to Blue):** `[0, 0, 0, 255]`

---

#### **2. Animation Message (ID: `1`)**
Sends a color gradient animation.

| Bytes | Field | Description |
| :--- | :--- | :--- |
| 0 | ID | `1` |
| 1 | Interpolation | `0`=Linear, `1`=Ease |
| 2 | Time Factor | `0`=Once, `1`=Repeat, `2`=Mirror |
| 3 | Duration (Mins) | Duration minutes part (0-59) |
| 4 | Duration (Secs) | Duration seconds part (0-59) |
| 5 | Duration (Centis) | Duration milliseconds/10 (0-99) |
| 6 | Color Point Count | Number of color points (`N`) that follow |
| 7+ | Color Points | `N` blocks of Color Point data (5 bytes each) |

**Color Point Structure (5 bytes per point):**

| Offset | Field | Description |
| :--- | :--- | :--- |
| +0 | Red | Red channel (0-255) |
| +1 | Green | Green channel (0-255) |
| +2 | Blue | Blue channel (0-255) |
| +3, +4 | Position | 16-bit integer (`position * 1000`) |

---

#### **3. Brightness Message (ID: `2`)**
Sets the overall brightness.

| Byte | Field | Description |
| :--- | :--- | :--- |
| 0 | ID | `2` |
| 1 | Brightness | Brightness value (0-100) |

*   **Example (Set brightness to 50%):** `[2, 50]`

---

#### **4. Fade Message (ID: `3`)**
Fades to a target color over a duration.

| Byte | Field | Description |
| :--- | :--- | :--- |
| 0 | ID | `3` |
| 1, 2 | Duration | 16-bit duration in milliseconds |
| 3 | Red | Target Red channel (0-255) |
| 4 | Green | Target Green channel (0-255) |
| 5 | Blue | Target Blue channel (0-255) |
| 6 | Ease Flag | `1` for ease, `0` for linear |

*   **Example (Fade to purple over 1.5s):** `[3, 5, 220, 128, 0, 128, 1]`

---

#### **5. Save/Load Message (ID: `4`)**
Saves the current state to a preset button or loads a state from it.

| Byte | Field | Description |
| :--- | :--- | :--- |
| 0 | ID | `4` |
| 1 | Save Flag | `1` to **save**, `0` to **load** |
| 2 | Button Index | The button index to use (0-3) |

*   **Example (Save to Button 1):** `[4, 1, 0]`
*   **Example (Load from Button 2):** `[4, 0, 1]`

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
