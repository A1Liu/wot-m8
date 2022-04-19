const std = @import("std");
const liu = @import("liu");

pub const Obj = u32;
const ArrayList = std.ArrayList;

extern fn stringObjExt(message: [*]const u8, length: usize) Obj;

pub extern fn clearObjBuffer() void;

pub extern fn logObj(id: Obj) void;

pub fn stringObj(bytes: []const u8) Obj {
    return stringObjExt(bytes.ptr, bytes.len);
}

const MessageBuffer = liu.RingBuffer(Message, 8);

const Message = struct {
    const Self = @This();

    final_mark: liu.Mark,

    fn deinit(self: *const Self) void {
        if (Bus.last_alloc.range + 1 < self.final_mark.range) {
            var range = Bus.last_alloc.range;
            const end = self.final_mark.range;

            while (range < end) : (range += 1) {
                const slot = range % Bus.alloc_block.len;
                liu.Alloc.free(Bus.alloc_block[slot]);
                Bus.alloc_block[slot] = &.{};
            }
        }

        Bus.last_alloc = self.final_mark;

        // pseudo-reset the range id's if possible
        if (Bus.last_alloc.range == Bus.next_alloc.range) {
            Bus.last_alloc.range = Bus.last_alloc.range % Bus.alloc_block.len;
            Bus.next_alloc.range = Bus.next_alloc.range % Bus.alloc_block.len;
        }
    }
};

const Bus = struct {
    var message_block: [8]Message = undefined;
    var next_message: usize = 0;
    var last_message: usize = 0;

    var messages: MessageBuffer = undefined;

    var alloc_block: [4][]u8 = [_][]u8{&.{}} ** 4;
    var next_alloc: liu.Mark = liu.Mark.ZERO;
    var last_alloc: liu.Mark = liu.Mark.ZERO;

    fn sendMessage() callconv(.C) void {
        if (next_message - last_message == message_block.len) {
            // bus is full
            return;
        }

        const message_slot = next_message % message_block.len;

        message_block[message_slot] = Message{
            .final_mark = Bus.next_alloc,
        };

        next_message += 1;
    }

    fn readMessage() ?Message {
        if (last_message == next_message) {
            next_message = 0;
            last_message = 0;
            return null;
        }

        const message = message_block[Bus.last_message];
        last_message += 1;

        return message;
    }
};

export fn sendData() void {
    Bus.messages = MessageBuffer.init();
    defer Bus.messages.deinit();

    _ = Bus.messages.pushMany(&.{});
    _ = Bus.messages.popMany(&.{});

    Bus.sendMessage();
}

export fn add(a: i32, b: i32) i32 {
    const log = "happy happy joy joy";
    // console_log_ex(log, log.len);

    const value = stringObj(log);

    if (Bus.readMessage()) |message| {
        defer message.deinit();

        _ = message;
    }

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
