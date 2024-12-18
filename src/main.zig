const std = @import("std");

const DATA_DIR = "data";
const DAY1_INPUT = "day1input.txt";

const Locations = struct { left: std.ArrayList(i32), right: std.ArrayList(i32) };

fn loadLocations(alloc: std.mem.Allocator) !Locations {
    var dataDir = try std.fs.cwd().openDir(DATA_DIR, .{});
    defer dataDir.close();

    var file = try dataDir.openFile(DAY1_INPUT, .{});
    defer file.close();

    var bufReader = std.io.bufferedReader(file.reader());
    var reader = bufReader.reader();

    var locations = Locations{ .left = std.ArrayList(i32).init(alloc), .right = std.ArrayList(i32).init(alloc) };

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
                    std.debug.print("error reading file: {any}\n", .{err});
                    return err;
                },
            }
        };

        const leftNum = try std.fmt.parseInt(i32, line[0..5], 10);
        const rightNum = try std.fmt.parseInt(i32, line[8..13], 10);

        try locations.left.append(leftNum);
        try locations.right.append(rightNum);

        lineFbs.reset();
    }

    return locations;
}

fn day1_part1(loc: Locations) !u32 {
    const leftCopy = try loc.left.clone();
    const rightCopy = try loc.right.clone();
    std.sort.block(i32, leftCopy.items, {}, std.sort.asc(i32));
    std.sort.block(i32, rightCopy.items, {}, std.sort.asc(i32));

    var dist: u32 = 0;
    for (loc.left.items, loc.right.items) |left, right| {
        dist += @abs(left - right);
    }

    return dist;
}

fn day1_part2(alloc: std.mem.Allocator, loc: Locations) !i32 {
    var rightOccurrences = std.AutoHashMap(i32, i32).init(alloc);
    defer rightOccurrences.deinit();

    for (loc.right.items) |item| {
        const entry = try rightOccurrences.getOrPutValue(item, 0);
        entry.value_ptr.* += 1;
    }

    var similarity: i32 = 0;
    for (loc.left.items) |item| {
        similarity += item * (rightOccurrences.get(item) orelse 0);
    }

    return similarity;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    const loc = try loadLocations(alloc);

    try stdout.print("Advent of Code 2024\n", .{});
    try stdout.print("-------------------\n", .{});
    try stdout.print("Day 1 Part 1: {!d}\n", .{day1_part1(loc)});
    try stdout.print("      Part 2: {!d}\n", .{day1_part2(alloc, loc)});

    try bw.flush();
}
