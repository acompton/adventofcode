const std = @import("std");

pub fn part1(text: []const u8) !i32 {
    var zeroCount: i32 = 0;
    var curPos: i32 = 50;

    var iter = std.mem.splitScalar(u8, text, '\n');
    var elem: ?[]const u8 = iter.first();
    while (elem != null) {
        const cur = elem.?;
        if (!std.mem.eql(u8, cur, "")) {
            const delta = @rem(try std.fmt.parseInt(i32, cur[1..cur.len], 10), 100);
            if (cur[0] == 'L') {
                curPos -= delta;
                if (curPos < 0) {
                    curPos += 100;
                }
            } else {
                curPos += delta;
                if (curPos > 99) {
                    curPos -= 100;
                }
            }

            if (curPos == 0) {
                zeroCount += 1;
            }
        }
        elem = iter.next();
    }
    return zeroCount;
}

pub fn part2(text: []const u8) !i32 {
    var zeroCount: i32 = 0;
    var curPos: i32 = 50;

    var iter = std.mem.splitScalar(u8, text, '\n');
    var elem: ?[]const u8 = iter.first();

    while (elem != null) {
        const cur = elem.?;
        if (!std.mem.eql(u8, cur, "")) {
            const origPos = curPos;
            const distance = try std.fmt.parseInt(i32, cur[1..cur.len], 10);
            const delta = @rem(distance, 100);

            zeroCount += @divTrunc(distance, 100);

            if (cur[0] == 'L') {
                curPos -= delta;
            } else {
                curPos += delta;
            }

            if (curPos <= 0 or curPos > 99) {
                if (origPos != 0) {
                    zeroCount += 1;
                }

                if (curPos < 0) {
                    curPos += 100;
                } else if (curPos > 99) {
                    curPos -= 100;
                } else if (curPos == 0) {}
            }
        }
        elem = iter.next();
    }

    return zeroCount;
}

test "day 1 part 1" {
    const text =
        \\L68
        \\L30
        \\R48
        \\L5
        \\R60
        \\L55
        \\L1
        \\L99
        \\R14
        \\L82
    ;

    const res = part1(text) catch unreachable;
    std.debug.print("Day 1 result: {d}\n", .{res});
}

test "day 1 part 2" {
    const text =
        \\L68
        \\L30
        \\R48
        \\L5
        \\R60
        \\L55
        \\L1
        \\L99
        \\R14
        \\L82
    ;

    const res = part2(text) catch unreachable;
    std.debug.print("Day 2 result: {d}\n", .{res});
    try std.testing.expectEqual(6, res);
}
