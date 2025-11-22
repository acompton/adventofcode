const std = @import("std");

// Common stuff
fn readFile(alloc: std.mem.Allocator, dataDir: std.fs.Dir, fileName: []const u8) ![]const u8 {
    const file = try dataDir.openFile(fileName, .{});
    defer file.close();

    return try file.readToEndAlloc(alloc, (try file.stat()).size);
}

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
    const content = try readFile(alloc, dataDir, "day3input.txt");
    defer alloc.free(content);

    var idx: usize = 0;
    var sum: i32 = 0;
    var enabled = true;

    const intParser = struct {
        fn parseInt(extContent: []const u8, extIdx: *usize) ?i32 {
            var parseEnd = extIdx.*;

            while (std.ascii.isDigit(extContent[parseEnd]) and (parseEnd - extIdx.*) < 4) {
                parseEnd += 1;
            }

            if (parseEnd - extIdx.* == 0) {
                return null;
            }

            const value = std.fmt.parseInt(i32, extContent[extIdx.*..parseEnd], 10) catch return null;

            extIdx.* = parseEnd;

            return value;
        }
    };

    while (idx < content.len - 8) {
        if (std.mem.eql(u8, content[idx .. idx + 4], "do()")) {
            idx += 4;
            enabled = true;
            continue;
        }

        if (std.mem.eql(u8, content[idx .. idx + 7], "don't()")) {
            idx += 7;
            enabled = false;
            continue;
        }

        if (enabled and std.mem.eql(u8, content[idx..(idx + 4)], "mul(")) {
            idx = idx + 4;

            const arg0 = intParser.parseInt(content, &idx) orelse continue;

            if (content[idx] == ',') {
                idx += 1;
            } else {
                continue;
            }

            const arg1 = intParser.parseInt(content, &idx) orelse continue;

            if (content[idx] == ')') {
                idx += 1;
                sum += arg0 * arg1;
            }

            continue;
        }

        idx += 1;
    }

    return sum;
}

// Day 4
const Day4 = struct {
    content: []const u8,
    rows: usize,
    cols: usize,

    fn pos(self: *Day4, row: i32, col: i32) ?u8 {
        if (row < 0 or row >= self.rows or col < 0 or col >= self.cols) {
            return null;
        }

        return self.content[@as(usize, @intCast(row)) * (self.cols + 1) + @as(usize, @intCast(col))];
    }

    fn countXmas_part1(self: *Day4, row: i32, col: i32) u32 {
        if (self.pos(row, col) != 'X') {
            return 0;
        }

        const tail = "MAS";

        var tails: u32 = 0;
        var dy: i32 = -1;
        while (dy <= 1) : (dy += 1) {
            var dx: i32 = -1;
            outer: while (dx <= 1) : (dx += 1) {
                if (dx == 0 and dy == 0) continue;

                var tx = col + dx;
                var ty = row + dy;
                for (tail) |match| {
                    if (self.pos(ty, tx) == match) {
                        tx += dx;
                        ty += dy;
                    } else {
                        continue :outer;
                    }
                }

                tails += 1;
            }
        }

        return tails;
    }

    fn countXmas_part2(self: *Day4, row: i32, col: i32) u32 {
        if (self.pos(row, col) == 'A') {
            if ((self.pos(row - 1, col - 1) == 'M' and self.pos(row + 1, col + 1) == 'S') or
                (self.pos(row - 1, col - 1) == 'S' and self.pos(row + 1, col + 1) == 'M'))
            {
                if ((self.pos(row + 1, col - 1) == 'M' and self.pos(row - 1, col + 1) == 'S') or
                    (self.pos(row + 1, col - 1) == 'S' and self.pos(row - 1, col + 1) == 'M'))
                {
                    return 1;
                }
            }
        }

        return 0;
    }

    const CountXmasResult = struct { part1: u32, part2: u32 };

    fn day4(alloc: std.mem.Allocator, dataDir: std.fs.Dir) !CountXmasResult {
        const content = try readFile(alloc, dataDir, "day4input.txt");
        defer alloc.free(content);
        return countContentXmas(content);
    }

    fn countContentXmas(content: []const u8) !CountXmasResult {
        const cols = std.mem.indexOfScalar(u8, content, '\n') orelse 0;
        const rows = (content.len + 1) / (cols + 1);

        var state = Day4{
            .content = content,
            .cols = cols,
            .rows = rows,
        };

        var total_part1: u32 = 0;
        var total_part2: u32 = 0;
        for (0..state.rows) |row| {
            for (0..state.cols) |col| {
                total_part1 += state.countXmas_part1(@intCast(row), @intCast(col));
                total_part2 += state.countXmas_part2(@intCast(row), @intCast(col));
            }
        }

        return .{ .part1 = total_part1, .part2 = total_part2 };
    }
};

test "day4 test 1" {
    const content =
        \\MMMSXXMASM
        \\MSAMXMSMSA
        \\AMXSXMAAMM
        \\MSAMASMSMX
        \\XMASAMXAMM
        \\XXAMMXXAMA
        \\SMSMSASXSS
        \\SAXAMASAAA
        \\MAMMMXMMMM
        \\MXMXAXMASX
    ;

    const res = try Day4.countContentXmas(content);
    try std.testing.expectEqual(18, res.part1);
    try std.testing.expectEqual(9, res.part2);
}

const Day5 = struct {
    fn day5(alloc: std.mem.Allocator, dataDir: std.fs.Dir) !u32 {
        return day5CheckContent(alloc, try readFile(alloc, dataDir, "day5input.txt"));
    }

    fn day5CheckContent(alloc: std.mem.Allocator, content: []const u8) u32 {
        const buf = std.io.fixedBufferStream(content);
        const bufReader = buf.reader();

        var line: [64]u8 = undefined;
        while (bufReader.streamUntilDelimiter(line, '\n', line.len)) |s| {

        }

        return @intCast(content.len);
    }
};

test "day 5 test 1" {
    const content =
        \\47|53
        \\97|13
        \\97|61
        \\97|47
        \\75|29
        \\61|13
        \\75|53
        \\29|13
        \\97|29
        \\53|29
        \\61|53
        \\97|53
        \\61|29
        \\47|13
        \\75|47
        \\97|75
        \\47|61
        \\75|61
        \\47|29
        \\75|13
        \\53|13
        \\
        \\75,47,61,53,29
        \\97,61,53,29,13
        \\75,29,13
        \\75,97,47,61,53
        \\61,13,29
        \\97,13,75,29,47
    ;

    try std.testing.expectEqual(143, Day5.day5CheckContent(std.testing.allocator, content));
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
    try stdout.print("Day 4: {d} {d}\n", try Day4.day4(alloc, dataDir));
    try stdout.print("Day 5: {d}\n", .{try Day5.day5(alloc, dataDir)});

    try bw.flush();
}
