const std = @import("std");
const liu = @import("liu");

pub const Obj = u32;

extern fn stringObjExt(message: [*]const u8, length: usize) Obj;

pub extern fn submitObj(id: Obj) void;
pub extern fn clearObjBuffer() void;

pub fn stringObj(bytes: []const u8) Obj {
    return stringObjExt(bytes.ptr, bytes.len);
}

const ArrayList = std.ArrayList;

export fn add(a: i32, b: i32) i32 {
    const log = "happy happy joy joy";
    // console_log_ex(log, log.len);

    const value = stringObj(log);

    submitObj(value);

    var list = ArrayList(i32).init(liu.Alloc);

    list.ensureUnusedCapacity(2) catch @panic("bro");

    list.append(a) catch @panic("welp");
    list.append(b) catch @panic("oof");

    var sum: i32 = 0;
    for (list.items) |i| {
        sum += i;
    }

    return sum;
}
