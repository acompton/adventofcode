//! By convention, root.zig is the root source file when making a library.
const std = @import("std");

pub const day1 = @import("day1.zig");

pub fn readFile(alloc: std.mem.Allocator, dataDir: std.fs.Dir, fileName: []const u8) ![]const u8 {
    const file = try dataDir.openFile(fileName, .{});
    defer file.close();

    return try file.readToEndAlloc(alloc, (try file.stat()).size);
}

test {
    _ = @import("day1.zig");
}

