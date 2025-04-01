## 📂 Repository Structure  
This repository contains two main folders:  
- **`GUI/`** → The graphical user interface for interactive simulations.  
- **`manuscript/`** → MATLAB scripts used to **reproduce** the results from the manuscript:  
  _"Emerging multidien cycles from partial circadian synchrony"_.  



# Emerging_multidien_cycles manuscript
Here, we provide the codes and a GUI to simulate a system of oscillators that can generate 'multdien' (multi-day) cycles by the interaction of circadian oscillators.



# Kuramoto-Sakaguchi Model GUI  

A **MATLAB graphical user interface (GUI)** for simulating the **Kuramoto-Sakaguchi Model**, which describes phase synchronization in a network of coupled oscillators. This tool allows users to **interactively tune parameters** and **visualize oscillator dynamics** in real time.  


## ✨ Features  
✅ **Dynamic Polar Plot**: Shows oscillators' phase positions with smooth animation.  
✅ **Kuramoto Order Parameter Plot**: Tracks system-wide synchronization over time.  
✅ **Periodogram (Frequency Spectrum Analysis)**: Computed at the **end** of the simulation.  
✅ **Interactive Controls**: Adjust model parameters in real-time:  
   - **α (Phase Lag)** – Controls phase shift in coupling.  
   - **b (Broadness)** – Defines the connectivity of the network.  
   - **ε (Zeitgeber Strength)** – Strength of external forcing.  
   - **p (Coupling Reduction)** – Probability of randomly removing links.  
✅ **Continuous Order Parameter Plot**: Retains past values instead of resetting.  
✅ **Smooth Oscillator Flow**: Improved animation for natural oscillator movement.  

## 🖥️ GUI Layout  
- **Left Panel** → **Polar Plot** (oscillators' phase positions + mean vector arrow)  
- **Top-Right** → **Kuramoto Order Parameter** (tracks synchronization over time)  
- **Bottom-Right** → **Periodogram** (frequency spectrum at the end of the simulation)  
- **Right Panel** → **Parameter inputs & Start button**  

## 🚀 How to Run  
1. Clone the repository:  
   ```bash
   git clone https://github.com/MGrauLeguia/Emerging_multidien_cycles.git
   cd Emerging_multidien_cycles
  
