# Brainfuck

There are a few files in here:

 - main.s:
    This file contains the main function.
    It reads a file from a command line argument and passes it to your brainfuck implementation.

 - read_file.s:
    Holds a subroutine for reading the contents of a file.
    This subroutine is used by the main function in main.s.

 - brainfuck.s:
    This is where we have our brainfuck implementation.
    We have defined a `brainfuck` subroutine that takes
    a single argument: a string holding the code to execute.

 - Makefile:
    A file containing compilation information.  If you have a working make,
    you can compile the code in this directory by simply running the command `make`.


You can add the file text with the brainfuck code and run the program using the commands:
```
make
```
```
./brainfuck file.txt
```
