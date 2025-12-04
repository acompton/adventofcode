const std = @import("std");

pub fn part1(text: []const u8) !u64 {
    var sum: u64 = 0;

    var iter = std.mem.splitScalar(u8, text, ',');
    var elem: ?[]const u8 = iter.first();
    while (elem) |cur| {
        const splitIdx = std.mem.indexOfScalar(u8, cur, '-') orelse 0;
        const endIdx = if (cur[cur.len - 1] == '\n') cur.len - 1 else cur.len;
        const firstNum = try std.fmt.parseInt(u64, elem.?[0..splitIdx], 10);
        const secondNum = try std.fmt.parseInt(u64, elem.?[splitIdx + 1 .. endIdx], 10);
        std.debug.assert(firstNum <= secondNum);

        var i = firstNum;
        while (i < secondNum) : (i += 1) {
            const log10 = std.math.log10_int(i);

            if (log10 & 0x1 == 0) {
                i = std.math.pow(u64, 10, log10 + 1);
                continue;
            }

            const halfDigits = std.math.pow(u64, 10, (log10 + 1) / 2);
            const upper = i / halfDigits;
            const lower = i % halfDigits;
            if (upper == lower) {
                sum += i;
            }
        }

        elem = iter.next();
    }
    return sum;
}

pub fn part2(text: []const u8) !u64 {
    var sum: u64 = 0;

    var iter = std.mem.splitScalar(u8, text, ',');
    var elem: ?[]const u8 = iter.first();
    while (elem) |cur| {
        const splitIdx = std.mem.indexOfScalar(u8, cur, '-') orelse 0;
        const endIdx = if (cur[cur.len - 1] == '\n') cur.len - 1 else cur.len;
        const firstNum = try std.fmt.parseInt(u64, elem.?[0..splitIdx], 10);
        const secondNum = try std.fmt.parseInt(u64, elem.?[splitIdx + 1 .. endIdx], 10);
        std.debug.assert(firstNum <= secondNum);

        for (firstNum..secondNum + 1) |i| {
            const log10 = std.math.log10_int(i);

            var power: u64 = 1;
            for (1..(log10 + 1) / 2 + 1) |_| {
                power *= 10;

                const lower = i % power;
                if (lower * 10 < power) {
                    continue;
                }

                var cmp: u64 = lower;
                while (cmp < i) {
                    cmp *= power;
                    cmp += lower;
                }

                if (cmp == i) {
                    sum += cmp;
                    break;
                }
            }
        }

        elem = iter.next();
    }
    return sum;
}

test "day 2 part 2" {
    std.debug.print("testing part 2\n", .{});
    try std.testing.expectEqual(11 + 22, part2("11-22"));
    try std.testing.expectEqual(99 + 111, part2("95-115"));
    try std.testing.expectEqual(999 + 1010, part2("998-1012"));
    try std.testing.expectEqual(1188511885, part2("1188511880-1188511890"));
    try std.testing.expectEqual(222222, part2("222220-222224"));
    try std.testing.expectEqual(0, part2("1698522-1698528"));
    try std.testing.expectEqual(446446, part2("446443-446449"));
    try std.testing.expectEqual(38593859, part2("38593856-38593862"));
    try std.testing.expectEqual(565656, part2("565653-565659"));
    try std.testing.expectEqual(824824824, part2("824824821-824824827"));
    try std.testing.expectEqual(2121212121, part2("2121212118-2121212124"));

    try std.testing.expectEqual(4174379265, part2("11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"));

    // 989133-1014784 match=989898 sum=989898
    // 989133-1014784 match=989989 sum=1979887
    // 989133-1014784 match=990990 sum=2970877
    // 989133-1014784 match=991991 sum=3962868
    // 989133-1014784 match=992992 sum=4955860
    // 989133-1014784 match=993993 sum=5949853
    // 989133-1014784 match=994994 sum=6944847
    // 989133-1014784 match=995995 sum=7940842
    // 989133-1014784 match=996996 sum=8937838
    // 989133-1014784 match=997997 sum=9935835
    // 989133-1014784 match=998998 sum=10934833
    // 989133-1014784 match=999999 sum=11934832
    // 989133-1014784 match=1001001 sum=12935833 <-- wrong
    // 989133-1014784 match=1010101 sum=13945934 <-- wrong
    try std.testing.expectEqual(989898 + 989989 + 990990 + 991991 + 992992 + 993993 + 994994 + 995995 + 996996 + 997997 + 998998 + 999999, part2("989133-1014784"));
}
