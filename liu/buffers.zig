const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;

const assert = std.debug.assert;

pub fn RingBuffer(comptime T: type, comptime len_opt: ?usize) type {
    return struct {
        const Self = @This();

        const Cond = if (len_opt) |buffer_len| struct {
            const Buffer = [buffer_len]T;
            const Alloc = void;

            const resizeAssumeEmpty = @compileError("this method is only available for dynamically sized RingBuffer values");

            fn init() Self {
                return Self{
                    .data = undefined,
                    .alloc = {},

                    .next = 0,
                    .last = 0,
                };
            }

            fn deinit(self: *Self) void {
                _ = self;
            }
        } else struct {
            const Buffer = []T;
            const Alloc = Allocator;

            fn init(size: usize, alloc: Allocator) !Self {
                const data = try alloc.alloc(T, size);

                return Self{
                    .data = data,
                    .alloc = alloc,

                    .next = 0,
                    .last = 0,
                };
            }

            fn deinit(self: *Self) void {
                self.alloc.free(self.data);
            }

            fn resizeAssumeEmpty(self: *Self, new_len: usize) !void {
                assert(self.isEmpty());

                self.next = 0;
                self.last = 0;

                if (self.alloc.resize(self.data)) |new_slice| {
                    self.data = new_slice;
                }

                // since the container is empty, we can just free previous buffer
                self.alloc.free(self.data);
                self.data = self.alloc.alloc(T, new_len);
            }
        };

        data: Cond.Buffer,
        alloc: Cond.Alloc,
        next: usize,
        last: usize,

        pub const init = Cond.init;
        pub const deinit = Cond.deinit;
        pub const resizeAssumeEmpty = Cond.resizeAssumeEmpty;

        pub fn resetCountersIfEmpty(self: *Self) bool {
            if (self.isEmpty()) {
                self.next = 0;
                self.last = 0;
                return true;
            }

            return false;
        }

        pub fn isEmpty(self: *const Self) bool {
            return self.next == self.last;
        }

        pub fn len(self: *const Self) usize {
            return self.next - self.last;
        }

        pub fn push(self: *Self, t: T) bool {
            return self.pushMany(&.{t}) > 0;
        }

        pub fn pop(self: *Self) ?T {
            var data = [1]T{undefined};

            if (self.popMany(&data).len > 0) {
                return data[0];
            }

            return null;
        }

        pub const SplitBuffer = struct {
            first: []T = &.{},
            second: []T = &.{},
            len: usize = 0,
        };

        pub fn circularIndex(begin: usize, end: usize, data: []T) SplitBuffer {
            assert(begin < end);

            var out = SplitBuffer{ .len = end - begin };
            assert(out.len <= data.len);

            if (begin == end) {
                return out;
            }

            var begin_idx = begin % data.len;
            var end_idx = end % data.len;

            if (begin_idx < end_idx) {
                out.first = data[begin_idx..end_idx];
            } else {
                out.first = data[begin_idx..data.len];
                out.second = data[0..end_idx];
            }

            return out;
        }

        pub fn allocPush(self: *Self, count: usize) SplitBuffer {
            const items_len = self.len();
            var out = SplitBuffer{};

            if (items_len == 0) {
                return out;
            }

            out.len = std.math.min(self.data.len -| items_len, count);

            var begin_idx = self.next % self.data.len;
            var end_idx = (self.next + out.len) % self.data.len;

            if (begin_idx < end_idx) {
                out.first = self.data[begin_idx..end_idx];
            } else {
                out.first = self.data[begin_idx..self.data.len];
                out.second = self.data[0..end_idx];
            }

            self.next += out.len;

            return out;
        }

        pub fn allocPop(self: *Self, count: usize) SplitBuffer {
            const items_len = self.len();
            var out = SplitBuffer{};

            if (items_len == 0) {
                return out;
            }

            out.len = std.math.min(items_len, count);

            var begin_idx = self.last % self.data.len;
            var end_idx = (self.last + out.len) % self.data.len;

            if (begin_idx < end_idx) {
                out.first = self.data[begin_idx..end_idx];
            } else {
                out.first = self.data[begin_idx..self.data.len];
                out.second = self.data[0..end_idx];
            }

            self.last += out.len;

            return out;
        }

        pub fn pushMany(self: *Self, data: []const T) usize {
            const allocs = self.allocPush(data.len);

            const split_point = allocs.first.len;
            mem.copy(T, allocs.first, data[0..split_point]);
            mem.copy(T, allocs.second, data[split_point..allocs.len]);

            return allocs.len;
        }

        pub fn popMany(self: *Self, data: []T) []T {
            const allocs = self.allocPop(data.len);

            const split_point = allocs.first.len;
            mem.copy(T, data[0..split_point], allocs.first);
            mem.copy(T, data[split_point..allocs.len], allocs.second);

            return data[0..allocs.len];
        }
    };
}

test {
    const TBuffer = RingBuffer(u8, 16);
    var messages: TBuffer = TBuffer.init();

    var i: u32 = 0;
    var cap: u32 = 0;
    while (i < 32) : (i += 1) {
        std.debug.print("hey {}\n", .{i});
        if (messages.push(12)) {
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

    try std.testing.expect(popCap == cap);
}
