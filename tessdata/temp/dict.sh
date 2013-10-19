#!/bin/bash
set -x
cp -f ../chi_sim.traineddata_bk chi_sim.traineddata
rm -f .*
combine_tessdata -u chi_sim.traineddata .
wordlist2dawg ../chi_sim.user-words chi_sim.word-dawg .unicharset
combine_tessdata -o chi_sim.traineddata chi_sim.word-dawg
#combine_tessdata -o chi_sim.traineddata chi_sim.word-dawg
cp -f chi_sim.traineddata ../
