// Copyright (C) 2025 William Welna (wwelna@occultusterra.com)

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

const std = @import("std");

pub const inferiusInterpretor = struct {
    const Self = @This();
    pub const exeParam = struct {
        program_pos:usize = 0,
        loop:bool = false,
        loop_start:usize = 0,
    };
    pub const Fail = error {
        Odd_Brackets,
        Odd_Brackets_Overflow,
    };
    mem:[]u8,
    swp:u8,
    pos_sav:usize,
    size:usize,
    pos:usize,
    toggle_swp:bool,
    toggle_stack:bool,
    program:[]const u8,
    output:std.ArrayList(u8),
    stack:std.ArrayList(u8),
    allocator:std.mem.Allocator,
    stdout:?*std.io.Writer,
    stdin:?*std.io.Reader,

    pub fn init(allocator:std.mem.Allocator, size:usize, program:[]const u8, stdin:?*std.io.Reader, stdout:?*std.io.Writer) !inferiusInterpretor {
        const mem = try allocator.alloc(u8, size);
        @memset(mem, 0);
        return .{
            .program = program,
            .mem = mem,
            .swp = 0,
            .pos_sav = 0,
            .allocator = allocator,
            .pos = 0,
            .toggle_swp = false,
            .toggle_stack = false,
            .size = size,
            .output = .empty,
            .stack = .empty,
            .stdin = stdin,
            .stdout = stdout,
        };
    }

    pub fn push(self:*Self, c:u8) !void {
        try self.stack.append(self.allocator, c);
    }

    pub fn pop(self:*Self) ?u8 {
        if(!self.toggle_stack) if(self.stack.items.len > 0) return self.stack.orderedRemove(0) else return null else return self.stack.pop(); 
    }

    pub fn execute(self:*Self, param:exeParam) !usize { 
        var program_pos = param.program_pos;
        var temp:u8 = undefined;
        while(program_pos < self.program.len) {
            switch(self.program[program_pos]) {
                '>' => {
                    if(self.pos < self.size-1) self.pos += 1 else self.pos %= self.size-1; 
                    program_pos += 1;
                },
                '<' => {
                    if(self.pos == 0) self.pos = self.size-1 else self.pos -= 1;
                    program_pos += 1;
                },
                '+' => {self.mem[self.pos] +%= 1; program_pos += 1;},
                '-' => {self.mem[self.pos] -%= 1; program_pos += 1;},
                '.' => {
                    if(self.stdout) |o| { // use output buffer if stdout not set
                        try o.print("{c}", .{self.mem[self.pos]}); try o.flush();
                    } else { try self.output.append(self.allocator, self.mem[self.pos]); }
                    program_pos += 1;
                },
                ',' => {
                        if(self.stdin) |i| { // ignore if stdin not set
                        self.mem[self.pos] = try i.takeByte();
                    } else self.mem[self.pos] = 0;
                    program_pos += 1;
                },
                // Extended Operations { left bitshift } right bitshift % swap ~ bit invert ^ xor | or & and
                '{' => {self.mem[self.pos] <<= 1; program_pos += 1;},
                '}' => {self.mem[self.pos] >>= 1; program_pos += 1;},
                '%' => {temp = self.mem[self.pos]; self.mem[self.pos] = self.swp; self.swp = temp; program_pos += 1;},
                '~' => {self.mem[self.pos] = ~self.mem[self.pos]; program_pos += 1;},
                '^' => {self.mem[self.pos] ^= self.swp; program_pos += 1;},
                '|' => {self.mem[self.pos] |= self.swp; program_pos += 1;},
                '&' => {self.mem[self.pos] &= self.swp; program_pos += 1;},
                '?' => { // Perfectly readable
                    std.debug.print("<{}/{}=>[{x}]->{}:{}/{}:{}>", .{self.pos, self.pos_sav, self.mem[self.pos], self.swp, self.toggle_stack, self.toggle_swp, self.stack.items.len});
                    program_pos += 1;
                },
                '*' => {self.pos_sav = self.pos; program_pos += 1;},
                '0' => {self.pos = self.pos_sav; program_pos += 1;},
                // Stack Operations : push ; pop # toggle between swp and pointer, a add s sub d div m mul c mod , L leftshift R rightshift O or X xor A and I invert
                ':' => {if(!self.toggle_swp) { try self.push(self.mem[self.pos]);} else { try self.push(self.swp);} program_pos += 1;},
                ';' => {temp = self.pop() orelse 0; if(!self.toggle_swp) self.mem[self.pos] = temp else self.swp = temp; program_pos += 1;},
                '#' => {self.toggle_swp = ~self.toggle_swp; program_pos += 1;},
                '@' => {self.toggle_stack = ~self.toggle_stack; program_pos += 1;},
                'a' => {temp = self.pop() orelse 0; temp +%= self.pop() orelse 0; try self.push(temp); program_pos += 1;},
                's' => {temp = self.pop() orelse 0; temp -%= self.pop() orelse 0; try self.push(temp); program_pos += 1;},
                'm' => {temp = self.pop() orelse 0; temp *%= self.pop() orelse 0; try self.push(temp); program_pos += 1;},
                'd' => {temp = self.pop() orelse 0; temp /= self.pop() orelse 0; try self.push(temp); program_pos += 1;},
                'c' => {temp = self.pop() orelse 0; temp %= self.pop() orelse 0; try self.push(temp); program_pos += 1;},
                'L' => {temp = self.pop() orelse 0; temp <<= 1; try self.push(temp); program_pos += 1;},
                'R' => {temp = self.pop() orelse 0; temp >>= 1; try self.push(temp); program_pos += 1;},
                'O' => {temp = self.pop() orelse 0; temp |= self.pop() orelse 0; try self.push(temp); program_pos += 1;},
                'X' => {temp = self.pop() orelse 0; temp ^= self.pop() orelse 0; try self.push(temp); program_pos += 1;},
                'A' => {temp = self.pop() orelse 0; temp &= self.pop() orelse 0; try self.push(temp); program_pos += 1;},
                'I' => {temp = self.pop() orelse 0; try self.push(~temp); program_pos += 1;},
                // Loops
                '[' => {
                    if(self.mem[self.pos] == 0) {
                        var nested:usize = 1;
                        program_pos += 1;
                        while(nested > 0 and program_pos < self.program.len) : (program_pos += 1) {
                            if(self.program[program_pos] == ']') nested -= 1 else if (self.program[program_pos] == '[') nested += 1;
                        }
                        if(nested != 0) return Fail.Odd_Brackets_Overflow;
                    } else {
                        program_pos += 1;
                        program_pos = try self.execute(.{.program_pos = program_pos, .loop = true, .loop_start = program_pos});
                    }
                },
                ']' => {
                    if(param.loop == true) {
                        if(self.mem[self.pos] == 0) {
                            return program_pos + 1;
                        } else program_pos = param.loop_start;
                    } else  { return Fail.Odd_Brackets; }
                },
                else => {program_pos += 1;},
            }
        }
        return self.program.len-1;
    }

    pub fn deinit(self:*Self) void {
        self.output.deinit(self.allocator);
        self.stack.deinit(self.allocator);
        self.allocator.free(self.mem);
    }
};

pub const inferiusCompiler = struct { }; // WIP