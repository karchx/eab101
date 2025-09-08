const std = @import("std");

pub const CommandTag = enum { Put, Get , Del };
pub const Command = union (CommandTag) {
    Put: struct {
        key: []const u8,
        val: []const u8,
    },
    Get: struct {
        key: []const u8,
    },
    Del: struct {
        key: []const u8,
    },
};

pub const RespTag = enum { Ok, Value, NotFound, Err };
pub const Response = union (RespTag) {
    Ok: void,
    Value: []const u8,
    NotFound: void,
    Err: []const u8,
};

pub fn parseLine(line: []const u8) !Command {
    var it = std.mem.tokenizeAny(u8, line, " \t\r\n");
    const op = it.next() orelse return error.BadRequest;
    switch (std.ascii.toUpper(op[0])) {
        'P' => { // PUT KEY VALUE
            const key = it.next() orelse return error.BadRequest;
            const rest = it.rest();
            if (rest.len == 0) return error.BadRequest;
            return Command{ .Put = .{ .key = key, .val = rest } };
        },
        'G' => { // GET KEY
            const key = it.next() orelse return error.BadRequest;
            return Command{ .Get = .{ .key = key } };
        },
        'D' => { // DEL KEY
            const key = it.next() orelse return error.BadRequest;
            return Command{ .Del = .{ .key = key } };
        },
        else => return error.BadRequest,
    }
}

pub fn writeResponse(w: anytype, resp: Response) !void {
    switch (resp) {
        .Ok => try w.print("OK\r\n", .{}),
        .NotFound => try w.print("NOT_FOUND\r\n", .{}),
        .Err => |msg| try w.print("ERR {s}\r\n", .{msg}),
        .Value => |val| try w.print("VALUE {d}\n{s}\n", .{val.len, val}),
    }
}
