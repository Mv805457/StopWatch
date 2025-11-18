import tkinter as tk
from tkinter import ttk
import subprocess, threading, time

# The compiled Verilog simulation file name
OUT_EXE = "tick.out"


# -------------------------------------------------------------
#  Function: compile_verilog()
#  Purpose : Compiles the Verilog stopwatch module + testbench
# -------------------------------------------------------------
def compile_verilog():
    subprocess.run(["iverilog", "-o", OUT_EXE, "stopwatch_tb.v", "stopwatch.v"])


# -------------------------------------------------------------
#  Function: run_action(cmd)
#  Purpose : Sends a command to Verilog, runs simulation,
#            and returns updated seconds + running state.
# -------------------------------------------------------------
def run_action(cmd):

    # 1. Write command to action.txt (this is how Python talks to Verilog)
    # Valid commands: STAR, STOP, TICK, RESE, NOP
    with open("action.txt", "w") as f:
        f.write(cmd)

    # 2. Run the Verilog simulation (stopwatch_tb.v)
    out = subprocess.run(["vvp", OUT_EXE], stdout=subprocess.PIPE, text=True)
    print(out.stdout)  # Debug output in console

    # 3. Read updated seconds from time.txt
    try:
        sec = int(open("time.txt").read().strip())
    except:
        sec = 0

    # 4. Read updated running state (1 = running, 0 = stopped)
    running = "RUNNING=1" in open("status.txt").read()

    # 5. Return updated values to GUI
    return sec, running


# =================================================================
#                     STOPWATCH GUI CLASS
#  =================================================================
#  This class builds the graphical interface and controls the
#  connection between the GUI buttons and the Verilog logic.
# =================================================================
class StopwatchGUI:

    # -----------------------------------------------
    # Constructor: sets up UI, compiles Verilog, etc.
    # -----------------------------------------------
    def __init__(self, root):
        self.root = root
        root.title("Verilog Stopwatch")

        # Internal Python variables
        self.seconds = 0
        self.running = False

        # Stopwatch display label
        self.label = ttk.Label(root, text="00:00", font=("Arial", 35))
        self.label.pack(pady=20)

        # Buttons row
        row = ttk.Frame(root)
        row.pack()

        ttk.Button(row, text="Start", command=self.start).grid(row=0, column=0, padx=5)
        ttk.Button(row, text="Stop", command=self.stop).grid(row=0, column=1, padx=5)
        ttk.Button(row, text="Reset", command=self.reset).grid(row=0, column=2, padx=5)
        ttk.Button(row, text="Exit", command=self.exit).grid(row=0, column=3, padx=5)

        # Initialize the communication files
        # These store stopwatch state between Verilog runs
        open("time.txt", "w").write("0")
        open("status.txt", "w").write("RUNNING=0")
        open("action.txt", "w").write("NOP")

        # Compile Verilog once at the start
        compile_verilog()

        # Perform a "NOP" (no action) to load initial state
        self.seconds, self.running = run_action("NOP")

        # Update the label visually
        self.update_label()

        # Start background ticker thread (runs every 1 sec)
        threading.Thread(target=self.ticker, daemon=True).start()


    # --------------------------------------------------
    #  Updates the display (MM:SS format)
    # --------------------------------------------------
    def update_label(self):
        m = self.seconds // 60
        s = self.seconds % 60
        self.label.config(text=f"{m:02d}:{s:02d}")


    # --------------------------------------------------
    # Background thread: sends TICK every 1 second.
    # Only increments time when running == True.
    # --------------------------------------------------
    def ticker(self):
        while True:
            if self.running:
                # Send TICK to Verilog (this increments by 1)
                sec, run = run_action("TICK")
                self.seconds = sec
                self.running = run

                # Update GUI safely
                self.root.after(0, self.update_label)

            # Real-time 1 second pause
            time.sleep(1)


    # --------------------------------------------------
    # Start button → tells Verilog to start counting
    # --------------------------------------------------
    def start(self):
        sec, run = run_action("STAR")
        self.seconds = sec
        self.running = run
        self.update_label()


    # --------------------------------------------------
    # Stop button → tells Verilog to stop counting
    # --------------------------------------------------
    def stop(self):
        sec, run = run_action("STOP")
        self.seconds = sec
        self.running = run
        self.update_label()


    # --------------------------------------------------
    # Reset button → clears counter + stops running
    # --------------------------------------------------
    def reset(self):
        sec, run = run_action("RESE")
        self.seconds = sec
        self.running = run
        self.update_label()


    # --------------------------------------------------
    # Exit button → close the window cleanly
    # --------------------------------------------------
    def exit(self):
        self.root.quit()


# =================================================================
#               MAIN WINDOW INITIALIZATION
# =================================================================
root = tk.Tk()
StopwatchGUI(root)
root.mainloop()
