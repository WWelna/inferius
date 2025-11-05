# inferius
Quod est superius est sicut quod inferius, et quod inferius est sicut quod est superius.

## Usage

```inferius -m <Size of scratch buffer, default to 30,000 bytes> <filename.inferius> "Arguments"```

## Additional Usage Notes

You may pass null for the stdin and stdout of inferius.inferiusInterpretor, disabling stdin as a NOOP and outputting results to an output buffer. Using the stack functions inferius.inferiusInterpretor.push() and inferius.inferiusInterpretor.pop(), you can pass data for execution of inferius instructions, and return the results using either the stack or inferius.inferiusInterpretor.output.items output buffer.

## Instructions

Unless it is a valid instruction, it treats it as a NOOP. It has complete compatability with BF otherwise.

### The Usual BF Instructions

|Instruction|Description|
|-|-|
|>|Increase Scratch Memory Pointer by 1 (Wraps back to zero)|
|<|Decrease Scratch Memory Pointer by 1 (Wraps back to end of scratch buffer)|
|+|Increase Byte pointed to by Scratch Memory Pointer by 1 (Wraps back to zero)|
|-|Increase Byte pointed to by Scratch Memory Pointer by 1 (Wraps back to 0xFF)|
|.|Print char to stdout pointed to by Scratch Memory Pointer|
|,|Read char from stdin and save to Scratch Memory pointed to by Scratch Memory Pointer|
|[|If Scratch location ponted to by Scratch Memory Pointer is 0, skips to matching ']', else executes until ']'|
|]|If Scratch location pointed to by Scratch Memory Pointer is not 0, jumps back to matching '[', else keeps executing|

### Instruction Extensions

|Instruction|Description|
|-|-|
|%|Swap Byte of the Scratch location pointed to by Scratch Memory Pointer with Byte Value of the SWP register|
|{|Binary Shift Left Byte of Scratch location pointed to by Scratch Memory Pointer|
|}|Binary Shift Right Byte of Scratch location pointed to by Scratch Memory Pointer|
|~|Invert Bits of Scratch location pointed to by Scratch Memory Pointer|
|^|XOR Byte of the Scratch location pointed to by Scratch Memory Pointer with the Byte Value stored in the SWP register|
|&|AND Byte of the Scratch location pointed to by Scratch Memory Pointer with the Byte Value stored in the SWP register|
|\||OR Byte of the Scratch location pointed to by Scratch Memory Pointer with the Byte Value stored in the SWP register|
|?|Print Debuging Information|
|*|Save Scratch Memory Pointer to SAV register|
|0|Restore Scratch Memory Pointer from SAV register (Initial State is zero)|

### Stack Instruction Extensions

|Instruction|Description|
|-|-|
|#|Toggle PUSH/POP Operation destination to SWP register or Scratch location pointed to by Scratch Memory Pointer (Defaults to Scratch location pointed to by Scratch Memory Pointer)|
|@|Toggle Stack Operation between FIFO and a FILO (Defaults to FIFO)|
|:|PUSH Byte Value pointed to by Scratch Memory Pointer onto the Stack|
|;|POP Byte Value from the Stack and Set Byte of location pointed to by Scratch Memory Pointer|
|a|POP Two Byte Values from the Stack, Add them together (Wrapping Overflow Values), and PUSH result back onto the Stack|
|s|POP Two Byte Values from the Stack, Subtract them (Wrapping Overflow Values), and PUSH result back onto the Stack|
|m|POP Two Byte Values from the Stack, Multiply them together (Wrapping Overflow Values), and PUSH result back onto the Stack|
|/|POP Two Byte Values from the Stack, Divide them, and PUSH result back onto the Stack|
|c|POP Two Byte Values from the Stack, perform Modulus Division on them, and PUSH result back onto the Stack|
|L|POP Byte Value from the Stack, perform a Binary Shift Left of it's value, and PUSH result back onto the Stack|
|R|POP Byte Value from the Stack, perform a Binary Shift Right of it's value, and PUSH result back onto the Stack|
|O|POP Two Byte Values from the Stack, OR the Byte Values together, and PUSH result back onto the Stack|
|A|POP Two Byte Values from the Stack, AND the Byte Values together, and PUSH result back onto the Stack|
|X|POP Two Byte Values from the Stack, XOR the Byte Values together, and PUSH result back onto the Stack|
|I|POP Byte from the Stack, Invert Bits, and PUSH result back onto the Stack|

## License

Copyright (C) 2025 William Welna (wwelna@occultusterra.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
