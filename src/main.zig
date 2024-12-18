const std = @import("std");

const DATA_DIR = "data";
const DAY1_INPUT = "day1input.txt";

fn day1(alloc: std.mem.Allocator) anyerror!u32 {
    var dataDir = try std.fs.cwd().openDir(DATA_DIR, .{});
    defer dataDir.close();

    var file = try dataDir.openFile(DAY1_INPUT, .{});
    defer file.close();

    var bufReader = std.io.bufferedReader(file.reader());
    var reader = bufReader.reader();

    var listLeft = std.ArrayList(i32).init(alloc);
    var listRight = std.ArrayList(i32).init(alloc);

    var line: [16]u8 = undefined;
    var lineFbs = std.io.fixedBufferStream(&line);
    const writer = lineFbs.writer();

    while (true) {
        reader.streamUntilDelimiter(writer, '\n', null) catch |err| {
            switch (err) {
                error.EndOfStream => {
                    lineFbs.reset();
                    break;
                },
                else => {
                    std.debug.print("[day1] error reading file: {any}\n", .{err});
                    return err;
                },
            }
        };

        const leftNum = try std.fmt.parseInt(i32, line[0..5], 10);
        const rightNum = try std.fmt.parseInt(i32, line[8..13], 10);

        try listLeft.append(leftNum);
        try listRight.append(rightNum);

        lineFbs.reset();
    }

    std.sort.block(i32, listLeft.items, {}, std.sort.asc(i32));
    std.sort.block(i32, listRight.items, {}, std.sort.asc(i32));

    var dist: u32 = 0;
    for (listLeft.items, listRight.items) |left, right| {
        dist += @abs(left - right);
    }

    return dist;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Advent of Code 2024\n", .{});
    try stdout.print("-------------------\n", .{});
    try stdout.print("Day 1: {!d}\n", .{day1(alloc)});

    try bw.flush();
}
