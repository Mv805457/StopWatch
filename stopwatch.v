// ================================================================
//  STOPWATCH LOGIC (Verilog)
//  ---------------------------------------------------------------
//  This module implements the *hardware logic* of a stopwatch.
//  It does NOT control real time. Instead, it updates the state
//  instantly whenever it receives a command (tick, start, stop, reset)
//  from the testbench.
// ================================================================

module stopwatch(
    input  wire clk,             // Simulation clock (used for sequential hardware behavior)
    input  wire do_tick,         // 1 = increment time by 1 second (if running = 1)
    input  wire do_reset,        // 1 = reset stopwatch to 0 and stop it
    input  wire do_start,        // 1 = set running state ON
    input  wire do_stop,         // 1 = set running state OFF
    input  wire [31:0] in_seconds, // Previously saved seconds (loaded from file)
    input  wire in_running,      // Previous running state (loaded from file)

    output reg  [31:0] out_seconds, // Updated seconds value
    output reg  out_running          // Updated running state
);

    // ------------------------------------------------------------
    //  ALWAYS BLOCK: Executes on every rising edge of the clock.
    //  This models a real hardware flip-flop update.
    // ------------------------------------------------------------
    always @(posedge clk) begin

        // --------------------------------------------------------
        // 1. Load previous state (like reading registers)
        //    This ensures we start with the last known values.
        // --------------------------------------------------------
        out_seconds <= in_seconds;
        out_running <= in_running;

        // --------------------------------------------------------
        // 2. Handle RESET command
        //    Highest priority:
        //      - reset time to 0
        //      - stop the stopwatch
        // --------------------------------------------------------
        if (do_reset) begin
            out_seconds <= 0;
            out_running <= 0;
        end

        // --------------------------------------------------------
        // 3. Handle START command
        //    Sets the stopwatch to running mode.
        // --------------------------------------------------------
        else if (do_start) begin
            out_running <= 1;
        end

        // --------------------------------------------------------
        // 4. Handle STOP command
        //    Freezes time by disabling running.
        // --------------------------------------------------------
        else if (do_stop) begin
            out_running <= 0;
        end

        // --------------------------------------------------------
        // 5. Handle TICK command
        //    Only increments if stopwatch is currently running.
        //    (Python sends TICK every 1 real second)
        // --------------------------------------------------------
        else if (do_tick && out_running) begin
            out_seconds <= in_seconds + 1;  // increment time
            out_running <= 1;                // stay in running mode
        end

        // --------------------------------------------------------
        // If none of the commands are active:
        //    Just keep the previous value (due to the initial load).
        // --------------------------------------------------------
    end

endmodule
