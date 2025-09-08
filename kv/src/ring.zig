const std = @import("std");
const hash32 = @import("hash.zig").hash32;

pub const Node = struct {
    id: []const u8, // 127.0.0.1:9001
    token: u32, // pos in the ring
};

pub const Ring = struct {
    nodes: []Node,

    pub fn init(allocator: std.mem.Allocator, addrs: [][]const u8, vnodes: u32) !Ring {
        var list = std.ArrayList(Node).init(allocator);
        for (addrs) |addr| {
            var i: u32 = 0;
            while (i < vnodes) : (i += 1) {
                var buf: [128]u8 = undefined;
                const s = try std.fmt.bufPrint(&buf, "{s}#{d}", .{addr, i});
                try list.append(.{
                    .id = try allocator.dupe(u8, addr),
                    .token = hash32(s),
                });
            }
        }

        const arr = try list.toOwnedSlice();
        std.sort.heap(Node, arr, {}, struct {
            fn less(_: void, a: Node, b: Node) bool { return a.token < b.token; }
        }.less);
        return .{ .nodes = arr };
    }

    pub fn deinit(self: *Ring, allocator: std.mem.Allocator) void {
        for (self.nodes) |n| allocator.free(n.id);
        allocator.free(self.nodes);
    }

    pub fn pick(self: *const Ring, key: []const u8) Node {
        const h = hash32(key);

        var lo: usize = 0;
        var hi: usize = self.nodes.len;
        while (lo < hi) {
            const mid = (lo + hi) / 2;
            if (self.nodes[mid].token >= h) hi = mid else lo = mid + 1;
        }
        return if (lo < self.nodes.len) self.nodes[lo] else self.nodes[0];
    }

    pub fn successors(self: *const Ring, start: Node, r: usize, out: []Node) void {
        var start_idx: usize = 0;
        for (self.nodes, 0..) |n, i| {
            if (n.token == start.token and std.mem.eql(u8, n.id, start.id)) {
                start_idx = i;
                break;
            }
        }
        var i: usize = 0;
        while (i < r) : (i += 1) {
            out[i] = self.nodes[@mod((start_idx + i), self.nodes.len)];
        }
    }
};
