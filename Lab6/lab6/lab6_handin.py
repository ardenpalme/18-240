#! usr/bin/env python
# POC script to make student files for a lab into a .tar file to submit
# to AutoLab. Students run in directory containing lab files to handin.
#
# Neil Ryan, nryan
# Irene Lin, iwl
#
# Known bugs:
#
# Send bug reports to iwl@andrew.cmu.edu

from commands import getoutput
from os.path import isfile
from os import listdir
import sys

sys.dont_write_bytecode = True;

andrewID = getoutput("whoami");

tarCmd = "tar -cvf " + andrewID + "_lab5" + ".tar *.sv *.asm";

print(tarCmd);
print(getoutput(tarCmd));
