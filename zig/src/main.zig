const std = @import("std");

fn day1(alloc: std.mem.Allocator, dataDir: std.fs.Dir) !struct { dist: u32, similarity: i32 } {
    var file = try dataDir.openFile("day1input.txt", .{});
    defer file.close();

    var bufReader = std.io.bufferedReader(file.reader());
    var reader = bufReader.reader();

    var leftLocations = std.ArrayList(i32).init(alloc);
    var rightLocations = std.ArrayList(i32).init(alloc);

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

        try leftLocations.append(leftNum);
        try rightLocations.append(rightNum);

        lineFbs.reset();
    }

    std.sort.block(i32, leftLocations.items, {}, std.sort.asc(i32));
    std.sort.block(i32, rightLocations.items, {}, std.sort.asc(i32));

    var dist: u32 = 0;
    for (leftLocations.items, rightLocations.items) |left, right| {
        dist += @abs(left - right);
    }

    var rightOccurrences = std.AutoHashMap(i32, i32).init(alloc);
    defer rightOccurrences.deinit();

    for (rightLocations.items) |item| {
        const entry = try rightOccurrences.getOrPutValue(item, 0);
        entry.value_ptr.* += 1;
    }

    var similarity: i32 = 0;
    for (leftLocations.items) |item| {
        similarity += item * (rightOccurrences.get(item) orelse 0);
    }

    return .{ .dist = dist, .similarity = similarity };
}

fn day2(dataDir: std.fs.Dir) !i32 {
    var file = try dataDir.openFile("day2input.txt", .{});
    defer file.close();

    var bufReader = std.io.bufferedReader(file.reader());
    var fileReader = bufReader.reader();

    var line: [16]u8 = undefined;
    var insertPos: usize = 0;
    var linePos: usize = 0;
    var safeReports: i32 = 0;

    while (true) {
        const byte = fileReader.readByte() catch {
            break;
        };

        if (byte == ' ' or byte == '\n') {
            const num = try std.fmt.parseInt(u8, line[insertPos..linePos], 10);
            line[insertPos] = num;
            insertPos += 1;
            linePos = insertPos;
        } else {
            line[linePos] = byte;
            linePos += 1;
        }

        if (byte == '\n') {
            for (0..linePos + 1) |i| {
                var lastNum: ?i32 = null;
                var lastDir: ?i32 = null;
                var isSafe = true;

                for (line[0..linePos], 0..linePos) |n, j| {
                    if (i == j) continue;

                    if (lastNum != null) {
                        const diff: i32 = @intCast(@abs(n - lastNum.?));
                        const dir =
                            if (diff != 0) @divExact(n - lastNum.?, diff) else 0;

                        if (lastDir == null) {
                            lastDir = dir;
                        }

                        if (diff == 0 or diff > 3 or dir != lastDir) {
                            isSafe = false;
                            break;
                        }
                    }

                    lastNum = n;
                }

                if (isSafe) {
                    safeReports += 1;
                    break;
                }
            }

            insertPos = 0;
            linePos = 0;
        }
    }

    return safeReports;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var dataDir = try std.fs.cwd().openDir("data", .{});
    defer dataDir.close();

    try stdout.print("Advent of Code 2024\n", .{});
    try stdout.print("-------------------\n", .{});
    try stdout.print("Day 1: dist={!d} similarity={!d}\n", try day1(alloc, dataDir));
    try stdout.print("Day 2: {d}\n", .{try day2(dataDir)});

    try bw.flush();
}
