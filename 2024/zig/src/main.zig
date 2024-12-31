const std = @import("std");

// Day 1

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

// Day 2

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

// Day 3
fn day3(alloc: std.mem.Allocator, dataDir: std.fs.Dir) !i32 {
    var file = try dataDir.openFile("day3input.txt", .{});
    defer file.close();

    const fsize = (try file.stat()).size;
    const content = try file.readToEndAlloc(alloc, fsize);
    defer alloc.free(content);

    var idx: usize = 0;
    var sum: i32 = 0;
    var do = true;

    while (idx < content.len - 8) {
        if (do) {
            if (std.mem.eql(u8, content[idx..(idx + 4)], "mul(")) {
                idx = idx + 4;

                var parseEnd = idx;
                while (std.ascii.isDigit(content[parseEnd]) and (parseEnd - idx) < 4) {
                    parseEnd += 1;
                }

                if (parseEnd - idx == 0) {
                    continue;
                }

                const arg0 = try std.fmt.parseInt(i32, content[idx..parseEnd], 10);

                idx = parseEnd;

                if (content[idx] == ',') {
                    idx += 1;
                } else {
                    continue;
                }

                parseEnd = idx;
                while (std.ascii.isDigit(content[parseEnd]) and (parseEnd - idx) < 4) {
                    parseEnd += 1;
                }

                if (parseEnd - idx == 0) {
                    continue;
                }
                const arg1 = try std.fmt.parseInt(i32, content[idx..parseEnd], 10);
                idx = parseEnd;

                if (content[idx] == ')') {
                    idx += 1;
                    sum += arg0 * arg1;
                }
            } else if (std.mem.eql(u8, content[idx .. idx + 7], "don't()")) {
                idx += 7;
                do = false;
            } else {
                idx += 1;
            }
        } else {
            if (std.mem.eql(u8, content[idx .. idx + 4], "do()")) {
                idx += 4;
                do = true;
            } else {
                idx += 1;
            }
        }
    }

    return sum;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    const dataDirPath = try std.fs.cwd().realpathAlloc(alloc, "../data");

    std.debug.print("Data path: {s}\n", .{dataDirPath});

    var dataDir = try std.fs.openDirAbsolute(dataDirPath, .{});
    defer dataDir.close();

    try stdout.print("Advent of Code 2024\n", .{});
    try stdout.print("-------------------\n", .{});
    try stdout.print("Day 1: dist={!d} similarity={!d}\n", try day1(alloc, dataDir));
    try stdout.print("Day 2: {d}\n", .{try day2(dataDir)});
    try stdout.print("Day 3: {d}\n", .{try day3(alloc, dataDir)});

    try bw.flush();
}
