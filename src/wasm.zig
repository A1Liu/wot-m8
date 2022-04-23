const std = @import("std");
const liu = @import("liu");
const types = @import("./types.zig");

const builtin = std.builtin;
const debug = std.log.debug;
const info = std.log.info;
const err = std.log.err;

const ArrayList = std.ArrayList;

pub const Obj = u32;

extern fn stringObjExt(message: [*]const u8, length: usize) Obj;
pub extern fn logObj(id: Obj) void;

pub extern fn clearObjBufferForObjAndAfter(objIndex: Obj) void;
pub extern fn clearObjBuffer() void;

extern fn exitExt(objIndex: Obj) noreturn;

pub fn exitFmt(comptime fmt: []const u8, args: anytype) noreturn {
    var _temp = liu.Temp.init();
    const temp = _temp.allocator();

    const allocResult = std.fmt.allocPrint(temp, fmt, args);
    const s = allocResult catch @panic("failed to print");

    exit(s);
}

pub fn exit(bytes: []const u8) noreturn {
    const obj = stringObjExt(bytes.ptr, bytes.len);
    return exitExt(obj);
}

pub fn stringObj(bytes: []const u8) Obj {
    return stringObjExt(bytes.ptr, bytes.len);
}

pub fn stringFmtObj(comptime fmt: []const u8, args: anytype) Obj {
    var _temp = liu.Temp.init();
    const temp = _temp.allocator();
    defer _temp.deinit();

    const allocResult = std.fmt.allocPrint(temp, fmt, args);
    const bytes = allocResult catch @panic("failed to print");

    return stringObjExt(bytes.ptr, bytes.len);
}

pub const strip_debug_info = true;
pub const have_error_return_tracing = false;

pub fn log(
    comptime message_level: std.log.Level,
    comptime scope: @Type(.EnumLiteral),
    comptime input_format: []const u8,
    args: anytype,
) void {
    if (@enumToInt(message_level) > @enumToInt(std.log.level)) {
        return;
    }

    var _temp = liu.Temp.init();
    const temp = _temp.allocator();
    defer _temp.deinit();

    const prefix = comptime prefix: {
        const prefix = "[" ++ message_level.asText() ++ "]: ";

        if (scope == .default) {
            break :prefix prefix;
        } else {
            break :prefix @tagName(scope) ++ prefix;
        }
    };

    const fmt = prefix ++ input_format ++ "\n";

    const allocResult = std.fmt.allocPrint(temp, fmt, args);
    const s = allocResult catch @panic("failed to print");

    const obj = stringObjExt(s.ptr, s.len);
    logObj(obj);

    clearObjBufferForObjAndAfter(obj);
}

pub fn panic(msg: []const u8, error_return_trace: ?*builtin.StackTrace) noreturn {
    @setCold(true);

    _ = error_return_trace;

    exit(msg);
}

const CommandData = union(enum) {
    char_in: u8,
};

const Command = struct {
    alloc_size: usize = 0,
    data: CommandData,
};

const CmdBuffer = liu.RingBuffer(Command, 16);
const CmdAlloc = liu.RingBuffer(u8, null);

var commands: CmdBuffer = CmdBuffer.init();
var cmd_alloc: CmdAlloc = undefined;
var next_cmd: Command = .{ .data = undefined };

var files: types.FileDb = undefined;

export fn charIn(code: u8) bool {
    next_cmd.data.char_in = code;
    const success = commands.push(next_cmd);
    if (success) {
        next_cmd.alloc_size = 0;
    }

    return success;
}

export fn init() void {
    cmd_alloc = CmdAlloc.init(4096, liu.Pages) catch @panic("CmdAlloc failure");
    files = types.FileDb.init(1024);
    files.arena.resetAndKeepLargestArena();

    const text = "Shamalamalan";

    debug("{s}", .{text});
    info("{s}", .{text});
    err("{s}", .{text});

    exitFmt("bb", .{});
}
