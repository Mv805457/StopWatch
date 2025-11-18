`timescale 1ns/1ps

// ======================================================================
//  TESTBENCH FOR STOPWATCH
//  ----------------------------------------------------------------------
//  This is NOT real hardware. This testbench acts like a bridge between
//  Python and the Verilog stopwatch module.
//
//  Python writes commands into text files:
//      - action.txt   → STAR, STOP, TICK, RESE
//      - time.txt     → previously saved seconds
//      - status.txt   → RUNNING=0 or RUNNING=1
//
//  Verilog reads these files, updates its internal state instantly,
//  and writes the updated values back to the text files.
//
//  Python uses this to simulate a real 1-second stopwatch.
// ======================================================================

module stopwatch_tb;

    // ------------------------------------------------------------
    // Testbench signals (inputs to the stopwatch module)
    // ------------------------------------------------------------
    reg clk = 0;
    reg do_tick = 0, do_reset = 0, do_start = 0, do_stop = 0;
    reg [31:0] in_seconds = 0;
    reg in_running = 0;

    // ------------------------------------------------------------
    // Outputs from the stopwatch module
    // ------------------------------------------------------------
    wire [31:0] out_seconds;
    wire out_running;

    // ------------------------------------------------------------
    // Instantiate the DUT (Device Under Test)
    // ------------------------------------------------------------
    stopwatch uut(
        .clk(clk),
        .do_tick(do_tick),
        .do_reset(do_reset),
        .do_start(do_start),
        .do_stop(do_stop),
        .in_seconds(in_seconds),
        .in_running(in_running),
        .out_seconds(out_seconds),
        .out_running(out_running)
    );

    // ------------------------------------------------------------
    // Generate a fake clock: toggles every 5ns
    // ------------------------------------------------------------
    always #5 clk = ~clk;

    // File handles
    integer f, r;

    // For reading 4-letter command from action.txt
    reg [7:0] c1, c2, c3, c4;

    // ------------------------------------------------------------
    // MAIN TESTBENCH LOGIC
    // ------------------------------------------------------------
    initial begin

        // ========================================================
        // 1. LOAD PREVIOUS SECONDS FROM time.txt
        //    (This allows stopwatch to continue from last value)
        // ========================================================
        f = $fopen("time.txt","r");
        if (f != 0) begin
            r = $fscanf(f, "%d", in_seconds);
            $fclose(f);
        end

        // ========================================================
        // 2. LOAD PREVIOUS RUNNING STATE FROM status.txt
        //    RUNNING=1 → running
        //    RUNNING=0 → stopped
        // ========================================================
        f = $fopen("status.txt","r");
        if (f != 0) begin
            r = $fscanf(f, "RUNNING=%d", in_running);
            $fclose(f);
        end

        // ========================================================
        // 3. READ THE ACTION FROM action.txt
        //    Only FIRST 4 characters matter:
        //      TICK → increment time by 1
        //      STAR → start stopwatch
        //      S
        TOP → stop stopwatch
        //      RESE → reset stopwatch
        // ========================================================
        do_tick = 0;
        do_reset = 0;
        do_start = 0;
        do_stop = 0;

        f = $fopen("action.txt", "r");
        if (f != 0) begin
            r = $fscanf(f, "%c%c%c%c", c1, c2, c3, c4);
            $fclose(f);

            if ({c1,c2,c3,c4} == "TICK") do_tick = 1;
            else if ({c1,c2,c3,c4} == "STAR") do_start = 1;
            else if ({c1,c2,c3,c4} == "STOP") do_stop = 1;
            else if ({c1,c2,c3,c4} == "RESE") do_reset = 1;
        end

        // ========================================================
        // 4. LET STOPWATCH UPDATE FOR A FEW CLOCK CYCLES
        //    This allows the always @(posedge clk) block to run
        // ========================================================
        repeat(4) @(posedge clk);

        // ========================================================
        // 5. SAVE UPDATED SECONDS BACK TO time.txt
        // ========================================================
        f = $fopen("time.txt", "w");
        $fwrite(f, "%0d\n", out_seconds);
        $fclose(f);

        // ========================================================
        // 6. SAVE UPDATED RUNNING STATE BACK TO status.txt
        // ========================================================
        f = $fopen("status.txt","w");
        $fwrite(f, "RUNNING=%0d\n", out_running);
        $fclose(f);

        // ========================================================
        // 7. PRINT DEBUG INFORMATION FOR PYTHON OR CMD
        // ========================================================
        $display("ACTION=%c%c%c%c  SECONDS=%0d  RUNNING=%0d",
                 c1, c2, c3, c4, out_seconds, out_running);

        // ========================================================
        // 8. END THE SIMULATION (Python calls vvp again later)
        // ========================================================
        $finish;
    end

endmodule
