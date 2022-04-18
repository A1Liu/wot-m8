const std = @import("std");
const liu = @import("liu");

pub const Obj = u32;

extern fn stringObjExt(message: [*]const u8, length: usize) Obj;

pub extern fn clearObjBuffer() void;

pub extern fn logObj(id: Obj) void;

pub fn stringObj(bytes: []const u8) Obj {
    return stringObjExt(bytes.ptr, bytes.len);
}

const Message = struct {};

const MessageBus = struct {
    var message_block: [8]Message = undefined;
    var messages: []Message = message_block[0..0];

    var alloc_block: [4][]u8 = [_][]u8{&.{}} ** 4;
    var next: liu.Mark = liu.Mark.ZERO;
    var last: liu.Mark = liu.Mark.ZERO;
};

export fn sendMessage() void {
    const block_id = MessageBus.next.range % MessageBus.alloc_block.len;
    _ = block_id;
}

const ArrayList = std.ArrayList;

export fn add(a: i32, b: i32) i32 {
    const log = "happy happy joy joy";
    // console_log_ex(log, log.len);

    const value = stringObj(log);

    MessageBus.messages.len += 1;

    var _temp = liu.LoopAlloc.init(1024, liu.Alloc);
    const temp = _temp.allocator();
    while (true) {
        defer _temp.loopCleanup();

        logObj(value);

        var list = ArrayList(i32).init(temp);

        list.ensureUnusedCapacity(2) catch @panic("bro");

        list.append(a) catch @panic("welp");
        list.append(b) catch @panic("oof");

        var sum: i32 = 0;
        for (list.items) |i| {
            sum += i;
        }

        return sum;
    }
}
