#!/bin/bash
for bench in hp apte xerox Camp91 Bozer97_1 Bozer97_2 Bazaraa75_1 Bazaraa75_2 Bozer91 Armour62_1 Armour62_2; do
    for jitter in 0 0.1 0.2; do
        for beta in 4 5 6; do
            for approach in U Up BLDP1 BLDP1p SP SPp SPpVI SPpVI3 RU RUpVI RUpVI3; do
                /Applications/Julia-0.4.5.app/Contents/Resources/julia/bin/julia single-trial.jl $bench $jitter $beta $approach
            done
        done
    done
done
