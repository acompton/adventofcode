const std = @import("std");
const _2025 = @import("_2025");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var buf: [1024]u8 = undefined;
    var stdout = std.fs.File.stdout().writer(&buf);
    defer stdout.interface.flush() catch {};

    const dataDirPath = try std.fs.cwd().realpathAlloc(alloc, "./data");

    var dataDir = try std.fs.openDirAbsolute(dataDirPath, .{});
    defer dataDir.close();

    const day1Input = try _2025.readFile(alloc, dataDir, "day1input.txt");
    const day2Input = try _2025.readFile(alloc, dataDir, "day2input.txt");

    try stdout.interface.print("{s}\t{s:15}\t{s:15}\n", .{"Day", "Part1", "Part2"});
    try printResult(&stdout.interface, 1, try _2025.day1.part1(day1Input), try _2025.day1.part2(day1Input));
    try printResult(&stdout.interface, 2, try _2025.day2.part1(day2Input), try _2025.day2.part2(day2Input));
}

fn printResult(out: *std.io.Writer, day: i32, part1: anytype, part2: anytype) !void {
    out.print("{d}\t{d:15}\t{d:15}\n", .{ day, part1, part2 }) catch {};
}
