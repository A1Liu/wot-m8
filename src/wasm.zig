const std = @import("std");
const liu = @import("liu");

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

extern fn exit() noreturn;

pub fn stringObj(bytes: []const u8) Obj {
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

    const obj = stringObj(msg);
    logObj(obj);

    exit();
}

const Message = union(enum) {
    char_in: u8,
};

const MessageBuffer = liu.RingBuffer(Message, 16);

var messages: MessageBuffer = MessageBuffer.init();

export fn charIn(code: u8) bool {
    return messages.push(Message{ .char_in = code });
}

export fn run() void {
    const text = "happy happy joy joy";

    debug("{s} b", .{text});
    info("a {s}", .{text});
    err("{s}c ", .{text});

    var i: u32 = 0;
    var cap: u32 = 0;
    while (i < 32) : (i += 1) {
        if (messages.push(Message{ .char_in = 1 })) {
            cap += 1;
        }
    }

    i = 0;
    var popCap: u32 = 0;
    while (i < 32) : (i += 1) {
        if (messages.pop()) |c| {
            _ = c;
            popCap += 1;
        }
    }

    info("{} {}", .{ cap, popCap });
}
