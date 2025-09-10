#UART (Universal Asynchronous Receiver/Transmitter)
##📌 Overview

This project implements a UART (Universal Asynchronous Receiver/Transmitter) in Verilog HDL, including Transmitter, Receiver, Baud Rate Generator, FIFO, and Top-Level UART module.
It is designed for FPGA platforms and has been verified through ModelSim simulations.

UART is one of the most widely used communication protocols in embedded systems, enabling reliable serial communication between digital devices.

##⚡ Features

✅ Fully parameterized design

✅ Supports 8 data bits

✅ 1 stop bit (configurable as 16 ticks)

✅ Baud rate: 115200 @ 50 MHz clock

✅ Integrated FIFO buffer (depth configurable)

✅ Modular design (Tx, Rx, Baud Generator, FIFO, Top module)

✅ Testbench included

##🛠️ Parameters
parameter BAUD_RATE = 115200,
parameter STOP_TICKS = 16,
parameter DATA_BITS  = 8,
parameter DIVISOR    = 27,  // for 50 MHz clock
parameter FIFO_DEPTH = 4

##📂 Project Structure
UART-Project/
│── src/
│   ├── transmitter.v
│   ├── receiver.v
│   ├── baud_gen.v
│   ├── fifo.v
│   ├── UART.v          # Top-level module
│
│── tb/
│   ├── tb_uart.v       # Testbench
│
│── docs/
│   ├── block_diagram.png
│   ├── simulation_waveform.png
│
│── README.md

##🚀 How to Run

Clone the repository:

git clone https://github.com/Muhammad-Taha-Ansari/UART.git
cd UART

Open the project in ModelSim/QuestaSim or Quartus.

Run the simulation:

Compile all source files in src/

Run the testbench in tb/

View waveforms and verify transmission/reception.

##🔮 Future Improvements

Support for parity bit

Configurable number of stop bits

Higher baud rate support

AXI/UART bridge

##👨‍💻 Author

###Muhammad Taha Ansari
###Electrical Engineering Student, NED University (2027)
🔗 linkedin.com/in/muhammad-taha-b93716299/
🔗 https://github.com/Muhammad-Taha-Ansari
