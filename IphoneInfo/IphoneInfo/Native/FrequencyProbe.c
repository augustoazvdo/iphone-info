#include "FrequencyProbe.h"

#include <mach/mach_time.h>
#include <stdint.h>

#define ADDS_PER_ITERATION 32
#define ITERATIONS 250000
#define RUNS 3

#if defined(__aarch64__)

#define ADD1 "add %0, %0, #1\n\t"
#define ADD8 ADD1 ADD1 ADD1 ADD1 ADD1 ADD1 ADD1 ADD1
#define ADD32 ADD8 ADD8 ADD8 ADD8

static uint64_t dependent_add_chain(uint64_t iterations) {
    uint64_t value = 0;
    for (uint64_t i = 0; i < iterations; i++) {
        // Each add depends on the previous one, so the chain retires one add per cycle.
        __asm__ volatile(ADD32 : "+r"(value));
    }
    return value;
}

double sonda_estimate_core_mhz(void) {
    mach_timebase_info_data_t timebase;
    if (mach_timebase_info(&timebase) != KERN_SUCCESS || timebase.denom == 0) {
        return 0;
    }

    double best = 0;
    for (int run = 0; run < RUNS; run++) {
        uint64_t start = mach_absolute_time();
        dependent_add_chain(ITERATIONS);
        uint64_t elapsed = mach_absolute_time() - start;

        double nanoseconds = (double)elapsed * timebase.numer / timebase.denom;
        if (nanoseconds <= 0) {
            continue;
        }
        double mhz = (double)ITERATIONS * ADDS_PER_ITERATION / nanoseconds * 1000.0;
        if (mhz > best) {
            best = mhz;
        }
    }
    return best;
}

#else

double sonda_estimate_core_mhz(void) {
    return 0;
}

#endif
