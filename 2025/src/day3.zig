const std = @import("std");

pub fn part1(text: []const u8) !u64 {
    var sum: u64 = 0;
    var iter = std.mem.splitScalar(u8, text, '\n');
    var elem: ?[]const u8 = iter.first();

    while (elem) |cur| : (elem = iter.next()) {
        var highestLeft: u8 = '0';
        var highestRight: u8 = '0';

        for (cur) |c| {
            if (highestRight > highestLeft) {
                highestLeft = highestRight;
                highestRight = c;
            } else if (c > highestRight) {
                highestRight = c;
            }
        }
        const num = (highestLeft - '0') * 10 + (highestRight - '0');
        sum += num;
    }

    return sum;
}

pub fn part2(text: []const u8) !u64 {
    var sum: u64 = 0;
    var iter = std.mem.splitScalar(u8, text, '\n');
    var elem: ?[]const u8 = iter.first();
    var highestSet: [12]u8 = undefined;

    while (elem) |cur| : (elem = iter.next()) {
        @memset(&highestSet, '0');

        for (cur) |c| {
            shiftIn(&highestSet, c);
        }

        var num: u64 = 0;
        for (0..highestSet.len) |i| {
            num *= 10;
            num += highestSet[highestSet.len-i-1] - '0';
        }

        sum += num;
    }

    return sum;
}

fn shiftIn(slice: []u8, c: u8) void {
    if (slice.len == 0) {
        return;
    }

    var shouldShift = c > slice[0];
    var i: usize = 0;
    while (!shouldShift and i < slice.len-1) : (i += 1) {
        shouldShift = slice[i] > slice[i+1];
    }

    if (shouldShift) {
        shiftIn(slice[1..], slice[0]);
        slice[0] = c;
    }
}

test "day 3 part 1" {
    try std.testing.expectEqual(98, part1("987654321111111"));
    try std.testing.expectEqual(89, part1("811111111111119"));
    try std.testing.expectEqual(78, part1("234234234234278"));
    try std.testing.expectEqual(92, part1("818181911112111"));

    try std.testing.expectEqual(357, part1(
        \\987654321111111
        \\811111111111119
        \\234234234234278
        \\818181911112111
    ));
}

test "day 3 part 2" {
    try std.testing.expectEqual(987654321111, part2("987654321111111"));
    try std.testing.expectEqual(811111111119, part2("811111111111119"));
    try std.testing.expectEqual(434234234278, part2("234234234234278"));
    try std.testing.expectEqual(888911112111, part2("818181911112111"));

    try std.testing.expectEqual(3121910778619, part2(
        \\987654321111111
        \\811111111111119
        \\234234234234278
        \\818181911112111
    ));
}
