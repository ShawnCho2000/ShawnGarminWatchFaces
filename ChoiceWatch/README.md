# ChoiceWatch

A premium, data-rich analog watch face for Garmin devices, specifically optimized for the Epix 2.

## Features

- **Bold Typography:** High-impact hours for quick readability.
- **Dynamic Sunrise/Sunset Indicator:** A custom-rendered SVG marker points to the time of the next sunrise or sunset event on the outer dial.
  - 🌅 **Yellow Marker:** Points to the upcoming sunrise.
  - 🌇 **Orange Marker:** Points to the upcoming sunset.
- **Sub-Dials:**
  - **Left Dial:** Battery percentage (with custom person icon).
  - **Bottom Dial:** Daily steps progress.
- **Live Metrics:** Heart rate, active calories, current temperature, and weather conditions.
- **Custom Assets:** Hand-crafted SVG hands and icons for a high-fidelity look.

## Installation

This project is built using the Garmin Connect IQ SDK. To run it in the simulator or sideload it to your watch:

1. Open the project in VS Code with the Monkey C extension installed.
2. Ensure your developer key is configured.
3. Run the "Run on Epix 2" launch configuration.

## Project Structure

- `source/`: Monkey C source code files.
- `resources/`: Fonts, drawables (SVGs), and layout definitions.
- `resources/drawables/`: Custom SVG assets including hands and weather indicators.
