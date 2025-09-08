const std = @import("std");

pub const KV = struct {
    map: std.StringHashMap([]u8),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) KV {
        return .{ .map = std.StringHashMap([]u8).init(allocator), .allocator = allocator };
    }

    pub fn deinit(self: *KV) void {
        var it = self.map.iterator();
        while (it.next()) |e| self.allocator.free(e.value_ptr.*);
        self.map.deinit();
    }

    pub fn put(self: *KV, key: []const u8, val: []const u8) !void {
        const dup = try self.allocator.dupe(u8, val);
        if (self.map.fetchPut(key, dup) catch null) |prev| {
            self.allocator.free(prev.value);
        }
    }

    pub fn get(self: *KV, key: []const u8) ?[]const u8 {
        return if(self.map.get(key)) |v| v else null;
    }

    pub fn del(self: *KV, key: []const u8) bool {
        if (self.map.fetchRemove(key)) |prev| {
            self.allocator.free(prev.value);
            return true;
        }
        return false;
    }
};
