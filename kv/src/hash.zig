const std = @import("std");

pub fn hash32(s: []const u8) u32 {
    // FNV-1a hash
    var h: u32 = 0x811C9DC5;
    for (s) |b| {
        h ^= b;
        h *%= 16777619;
    }
    return h;
}
