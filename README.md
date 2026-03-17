# Aircraft-to-Satellite Communication for ADS-B Out ✈️📡

## Overview
This repository features a complex simulation of the **ADS-B (Automatic Dependent Surveillance-Broadcast)** system, bridging aviation surveillance with satellite communication. The project models a transatlantic flight trajectory and evaluates communication reliability between the aircraft, ground stations, and the **Iridium NEXT** satellite constellation.

Developed as a final project for the **Radiocommunications** course, it combines 3D orbital mechanics with link budget analysis and signal processing.

## 📂 Repository Structure

* `DOCUMENTATIE_RC_PROIECT_FINAL.pdf`: Comprehensive technical report detailing the ADS-B protocol, satellite constellation geometry, and link budget calculations.
* `gui.m`: Source code for the interactive MATLAB Graphical User Interface (GUI) used to control and visualize the simulation.
* `proiect_rc.mlx`: MATLAB Live Script containing the core simulation logic, 3D scenario generation, and data analysis.

---

## 📄 Key Concepts & Project Features

### 1. ADS-B Technology & Satellite Integration
* **System Modeling:** Implementation of ADS-B Out functionality, broadcasting GNSS position, altitude, and aircraft status at 1090 MHz.
* **Space-Based ADS-B:** Analysis of how satellite constellations (like Iridium NEXT) provide global coverage, especially in oceanic areas where terrestrial radar is unavailable.

### 2. 3D Flight Simulation & Orbital Mechanics
* **Transatlantic Trajectory:** Realistic 3D path modeling using `geoTrajectory` for a flight between **JFK (New York)** and **Avram Iancu (Cluj-Napoca)**.
* **Constellation Modeling:** Deployment of 66 satellites across 6 orbital planes to simulate the Iridium NEXT network.
* **Access Analysis:** Dynamic calculation of "Access" intervals between the aircraft and both ground stations and satellites based on line-of-sight (LoS).

### 3. Link Budget & Antenna Theory
* **Signal Analysis:** Evaluation of communication quality using the Phased Array System Toolbox.
* **Antenna Patterns:** Comparative analysis of different antenna models (Isotropic vs. Custom patterns) and their impact on signal reception at high altitudes.

---

## 🛠️ Technologies & Tools Used
* **Programming Language:** MATLAB
* **Toolboxes:** Satellite Communications Toolbox, Phased Array System Toolbox, Aerospace Toolbox.
* **Core Functions:** `satelliteScenario`, `geoTrajectory`, `access`, `linkBudget`.

---

## 🖥️ Interactive GUI
The project includes a custom-built MATLAB interface (`gui.m`) that allows users to:
* **Initialize Scenarios:** Set up the global environment and satellite planes.
* **Real-time Visualization:** Launch a 3D viewer to track the aircraft's progress across the Atlantic.
* **Data Export:** Generate access reports and communication statistics directly from the menu.

---

## 👨‍💻 Authors
**Mădălin Gavrilaș** & **David Adelin Man** *Technical University of Cluj-Napoca (UTCN)* *Faculty of Electronics, Telecommunications and Information Technology (ETTI)*
