//! By convention, root.zig is the root source file when making a library.
const std = @import("std");

pub const day1 = @import("day1.zig");
pub const day2 = @import("day2.zig");
pub const day3 = @import("day3.zig");

pub fn readFile(alloc: std.mem.Allocator, dataDir: std.fs.Dir, fileName: []const u8) ![]const u8 {
    const file = try dataDir.openFile(fileName, .{});
    defer file.close();

    return try file.readToEndAlloc(alloc, (try file.stat()).size);
}

test {
    _ = @import("day1.zig");
    _ = @import("day2.zig");
    _ = @import("day3.zig");
}
