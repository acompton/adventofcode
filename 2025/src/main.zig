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

    try stdout.interface.writeAll("Day\tPart1\tPart2\n");
    try printResult(&stdout.interface, 1, try _2025.day1.part1(day1Input), try _2025.day1.part2(day1Input));
}

fn printResult(out: *std.io.Writer, day: i32, part1: i32, part2: i32) !void {
    out.print("{d}\t{d}\t{d}\n", .{ day, part1, part2 }) catch {};
}
