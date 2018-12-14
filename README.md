# Snake Xenia
A clone of the classic Snake Xenia game built with x86 Assembly.


![Snake-Xenia.Png](https://i.postimg.cc/Dmkcb7tY/Snake-Xenia.png)


# How To Run
1. Get [DoxBox Portable](https://portableapps.com/apps/games/dosbox_portable)
2. Get [NASM assembler](https://www.nasm.us/)
3. Open up dobox portable, move into the project directory.
4. Run `nasm.exe main.asm -o output.com`
5. Run `output.com`



# Files

- arena.asm: defines the construction of arena.
- audio.asm: defines the working of audio.
- food.asm: defines mechanims for appearance and eating of food.
- snake.asm: defines the movement of snake.
- utility.asm: defines some utility functions.
- main.asm: defines the main loop.

### A note on indentation
The indentation followed in this project differs from the standard indentation found in most x86 books. I developed this style and I believe it's more intuitive for people coming from higher level languages.

