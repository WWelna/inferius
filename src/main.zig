// Copyright (C) 2025 William Welna (wwelna@occultusterra.com)

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following condition.

// * The above copyright notice and this permission notice shall be included in
//   all copies or substantial portions of the Software.

// In addition, the following restrictions apply:

// * The software, either in source or compiled binary form, with or without any
//   modification, may not be used with or incorporated into any other software
//   that used an Artificial Intelligence (AI) model and/or Large Language Model
//   (LLM) to generate any portion of that other software's source code, binaries,
//   or artwork.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

const VERSION_STRING = "0.0.1";

const std = @import("std");
const clap = @import("clap");
const inferius = @import("inferius");

pub fn halp(mauh: *std.io.Writer) !void {
    try mauh.print("Quod est superius est sicut quod inferius, et quod inferius est sicut quod est superius.\n", .{});
    try mauh.flush();
}

pub fn version(mauh: *std.io.Writer) !void {
    try mauh.print("inferius {s}\n", .{VERSION_STRING});
    try mauh.flush();
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var stdout_buffer: [128]u8 = undefined;
    var stdin_buffer: [128]u8 = undefined;

    var stdout_writer_wrapper = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout: *std.io.Writer = &stdout_writer_wrapper.interface;

    var stdin_reader_wrapper = std.fs.File.stdin().reader(&stdin_buffer);
    const stdin: *std.io.Reader = &stdin_reader_wrapper.interface;

    var memory: usize = 30000;

    const params = comptime clap.parseParamsComptime(
        \\-h, --help             Display this help and exit.
        \\-v, --version          Display Version
        \\-m, --memory <usize>   Size of scratch buffer, default to 30,000 bytes
        \\<str>...
        \\
    );

    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, clap.parsers.default, .{
        .diagnostic = &diag,
        .allocator = allocator,
    }) catch |err| {
        try diag.reportToFile(.stderr(), err);
        return;
    };
    defer res.deinit();

    if (res.args.version != 0) {
        try version(stdout);
        return;
    }
    if (res.args.help != 0) {
        try halp(stdout);
        return;
    }
    if (res.args.memory) |m| memory = m;
    if (res.positionals[0].len > 0 and res.positionals[0].len < 3) {
        const d = std.fs.cwd().readFileAlloc(allocator, res.positionals[0][0], 1024 ^ 2) catch |err| {
            std.debug.print("Can't open '{s}': {s}\n", .{ res.positionals[0][0], @errorName(err) });
            return;
        };
        defer allocator.free(d);
        var vm = try inferius.inferiusInterpretor.init(allocator, memory, d, stdin, stdout);
        if (res.positionals[0].len == 2) {
            for (res.positionals[0][1]) |c| {
                try vm.push(c);
            }
        }
        _ = try vm.execute(.{});
        defer vm.deinit();
        try stdout.flush();
        return;
    }
}
