```text
           (¯`*•.¸,¤°´✿.｡.:* "" *.:｡.✿`°¤,¸.•*´¯)
  _        __         _                                   
 \ \      / /  ___  | |   ___    ___    _ __ ___     ___ 
  \ \ /\ / /  / _ \ | |  / __|  / _ \  | '_ ` _ \   / _ \
   \ V  V /  |  __/ | | | (__  | (_) | | | | | | | |  __/
    \_/\_/    \___| |_|  \___|  \___/  |_| |_| |_|  \___|
```

This is Shachar and Sahar's project at the course SW-HW Codesign. 
For our project we chose to dive into the benchmarks of unpack_sequence and json_dumps.

This repository contains:
- benchmarks
    - this folder contains:
        Custom benchmark we created and will be copied into pyperformance/benchmarks folder.
        MANIFEST file that will also be copied to pyperformance/benchmarks folder
- report_unpack_sequence.txt and report_json_dumps.txt that document our project.
- script_unpack_sequence.sh and script_json_dumps.sh that will run and output different reports as detailed in each of the text files. 
- trash.cpp - a program that put garbage data in the cache.
- prompt.txt - a text file that contains the prompts we used.
- results_bm* folders that contain the output of the script_unpack_sequence.sh and script_json_dumps.sh scripts
    * this is the info we provided in report_unpack_sequence.txt and report_json_dumps.txt

How to run our code?
- connect to QEMU
- create a python3-dbg virtual environment:
    ```bash
    sudo apt update
    sudo apt install python3.10-venv
    python3-dbg -m venv venv-dbg
    source venv-dbg/bin/activate
    pip install --upgrade pip
    pip install pyperformance
    pip install git+https://github.com/python/pyperformance.git
    git clone https://github.com/python/pyperformance.git
    cd pyperformance
    pip install -e .
    ```
*note: pyperformance will be our work path, all outputs will be created in pyperformance directory.

- clone our repository:
    git clone https://github.com/ShacharDeyi/SWHW_codesign
- run the unpack_sequence analysis 
    cp SWHW_codesign/script_unpack_sequence.sh .
    chmod 777 script_unpack_sequence.sh
    ./script_unpack_sequence.sh
- run the json_dumps analysis   
    cp SWHW_codesign/script_json_dumps.sh .
    chmod 777 script_json_dumps.sh
    ./script_json_dumps.sh

What does each script do?
- builds a python environment 
- copies files, clones repositories and downloads relevant libraries
- runs perf tools and creates an output folder for each custom benchmark that contains:
    - perf_report.txt as shown in the project's example
    - flamegraph
    - statistics report


Shachar Deyi 208695379
Sahar Liz Ohana 209312966

Thanks For Reading!
```text
	⣀⡤⢤⣄⠀⣠⡤⣤⡀⠀⠀⠀
⠀⠀⢀⣴⢫⠞⠛⠾⠺⠟⠛⢦⢻⣆⠀⠀
⠀⠀⣼⢇⣻⡀⠀⠀⠀⠀⠀⠀⢸⡇⢿⣆⠀
⠀⢸⣯⢦⣽⣷⣄⡀⠀⢀⣴⣿⣳⣬⣿⠀
⢠⡞⢩⣿⠋⠙⠳⣽⢾⣯⠛⠙⢹⣯⠘⣷
⠀⠈⠛⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠋⠁⠀⠀
```