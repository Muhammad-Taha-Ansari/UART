# 🚀 Universal Asynchronous Receiver/Transmitter (UART)

[![Verilog](https://img.shields.io/badge/HDL-Verilog-blue.svg)]()
[![FPGA](https://img.shields.io/badge/Target-FPGA-green.svg)]()
[![Simulation](https://img.shields.io/badge/Tool-ModelSim-orange.svg)]()

A **Verilog HDL** implementation of a **UART** system including **Transmitter, Receiver, Baud Generator, FIFO**, and a **Top module**.  
The design is fully parameterized, modular, and tested on a 50 MHz clock source.

---

## 📖 Overview
This project demonstrates the design and implementation of a UART, a widely used serial communication protocol for asynchronous data transfer.  
It is designed for FPGA/ASIC projects and verified through simulation.

---

## ✨ Features
- Parameterized data bits, stop bits, and baud rate divisor  
- Independent **Transmitter** and **Receiver** modules  
- **FIFO buffers** for TX and RX  
- **Baud rate generator** for clock division  
- Fully tested with a dedicated **testbench**

---

## ⚙️ Parameters
```verilog
parameter BAUD_RATE = 115200;
parameter STOP_BIT  = 16;    // stop ticks
parameter DATA_BITS = 8;     // bits per frame
parameter DIVISOR   = 27;    // baud divisor (50 MHz / BAUD_RATE)
parameter FIFO      = 4;     // FIFO depth


## 📂 Repository Structure
