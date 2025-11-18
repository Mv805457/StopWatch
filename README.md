# ⏱️ Verilog + Python Real-Time Stopwatch

A Hardware Stopwatch Simulated in Verilog and Controlled Using a Python GUI

📌 Overview

This project implements a real-time stopwatch using a hybrid hardware + software system:

🖥 Python Tkinter GUI controls the stopwatch

🔧 Verilog HDL performs the stopwatch logic

📂 Text files act as communication channels

⏳ Python provides actual 1-second timing

This results in a fully functional, real-time stopwatch built on top of real digital logic.

🧠 Project Highlights

✔ Real-time stopwatch

✔ Start / Stop / Reset / Exit

✔ GUI showing MM:SS

✔ Verilog sequential flip-flop logic

✔ Python thread sends real-time ticks

✔ File-based IPC between Python & Verilog

✔ Clean modular structure

✔ Resume stopwatch from last state

🛠️ Technologies Used

Verilog HDL

Icarus Verilog (iverilog, vvp)

Python 3

Tkinter GUI

Multithreading

File-based IPC

Digital synchronous design

📁 Project Structure
StopWatchProject/
│

├── stopwatch.v          # Verilog hardware logic

├── stopwatch_tb.v       # Verilog testbench (reads/writes files)

│
├── gui.py               # Python GUI controller

├── action.txt           # Python -> Verilog command

├── time.txt             # Stores seconds

├── status.txt           # Stores running or not

│

├── tick.out             # Compiled Verilog simulation (auto-generated)

└── README.md            # Documentation


⚙️ How It Works
1️⃣ Python sends a command → Verilog reads it

Python writes one of the commands below into action.txt:

Command	Meaning
STAR	Start stopwatch
STOP	Stop stopwatch
RESE	Reset stopwatch
TICK	Increase time by 1
NOP	No operation

Then Python runs:

vvp tick.out

2️⃣ Verilog processes logic instantly

The Verilog testbench:

Reads time.txt

Reads status.txt

Applies the command (start/stop/reset/tick)

Writes back updated values

This happens in nanoseconds, not real time.

3️⃣ Python enforces real passing of time

Python uses:

time.sleep(1)


so every real second → Python sends TICK to Verilog.

4️⃣ GUI updates live

The Tkinter window displays the updated stopwatch value.

🖥️ GUI Preview
+----------------------+
|        00:37         |
| Start  Stop  Reset   |
|         Exit         |
+----------------------+

🚀 How to Run the Project
✔ Step 1 — Install Icarus Verilog

Windows: https://bleyer.org/icarus/

Linux/macOS:

sudo apt install iverilog

✔ Step 2 — Run the GUI

Navigate into the project folder:

python gui.py


The stopwatch window will appear.

🧪 Testing the Verilog Simulation Manually (Optional)

Compile:

iverilog -o tick.out stopwatch_tb.v stopwatch.v


Run:

vvp tick.out


Send commands:

echo STAR > action.txt
vvp tick.out

echo TICK > action.txt
vvp tick.out

echo STOP > action.txt
vvp tick.out

🔍 What This Project Demonstrates

Hardware-software interaction

Sequential circuit design

Real-time simulation control

Python GUI development

Digital logic (counters, state machines)

File-based process communication

Multithreading and event loops

This is an excellent project for interviews, portfolios, or university presentations.

📘 Future Improvements

⏱ Lap timer

⏳ Countdown mode

🖥 FPGA implementation

🎨 Improved GUI styling

🔌 Socket-based communication (replace text files)

🐍 Port to PyQt / Kivy

⏱ Millisecond support

📝 License

MIT — free to use and modify.

🤝 Contributing

Pull requests are welcome.
Open issues for suggestions or improvements.
