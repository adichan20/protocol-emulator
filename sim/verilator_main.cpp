#include "Vdut.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <string>

int main(int argc, char **argv)
{
    VerilatedContext context;

    // Pass command-line arguments to Verilator
    context.commandArgs(argc, argv);

    // Enable waveform tracing
    context.traceEverOn(true);

    // Instantiate the generated DUT/testbench model
    Vdut dut{&context};

    // First argument after executable is the design name
    // Example:
    // ./Vdut uart_tx
    std::string name = (argc > 1) ? argv[1] : "wave";

    // Generated waveform path
    std::string waveform = "waves/" + name + ".vcd";

    // Set up VCD tracing
    VerilatedVcdC trace;
    dut.trace(&trace, 99);
    trace.open(waveform.c_str());

    // Run until the SV testbench calls $finish
    while (!context.gotFinish())
    {
        dut.eval();

        trace.dump(context.time());

        // Advance simulation by 1 time unit
        context.timeInc(1);
    }

    // Final evaluation/cleanup
    dut.final();

    trace.close();

    return 0;
}