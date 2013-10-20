#!/bin/bash
set -x
#cp -f ../chi_sim.traineddata_bk chi_sim.traineddata
#rm -f .*
#combine_tessdata -u chi_sim.traineddata .
##wordlist2dawg ../chi_sim.user-words chi_sim.word-dawg .unicharset
mv .unicharset chi_sim.unicharset
combine_tessdata -o chi_sim.traineddata chi_sim.unicharset 
mv .unicharambigs chi_sim.unicharambigs
combine_tessdata -o chi_sim.traineddata chi_sim.unicharambigs 
cp -f chi_sim.traineddata ../
