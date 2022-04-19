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
                assert(self.len() == 0);

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
            if (self.len() == 0) {
                self.next = 0;
                self.last = 0;
                return true;
            }

            return false;
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

        pub fn pushMany(self: *Self, data: []const T) usize {
            const items_len = self.len();

            const push_len = std.math.min(self.data.len -| items_len, data.len);

            var begin_idx = self.next % self.data.len;
            var end_idx = (self.next + push_len) % self.data.len;

            if (begin_idx < end_idx) {
                mem.copy(T, self.data[begin_idx..end_idx], data[0..push_len]);
            } else {
                const split_point = self.data.len - begin_idx;
                mem.copy(T, self.data[begin_idx..self.data.len], data[0..split_point]);
                mem.copy(T, self.data[0..end_idx], data[split_point..push_len]);
            }

            self.next += push_len;

            return push_len;
        }

        pub fn popMany(self: *Self, data: []T) []T {
            const items_len = self.len();

            const pop_len = std.math.min3(self.data.len, items_len, data.len);

            var begin_idx = self.last % self.data.len;
            var end_idx = (self.last + pop_len) % self.data.len;

            if (begin_idx < end_idx) {
                mem.copy(T, data[0..pop_len], self.data[begin_idx..end_idx]);
            } else {
                const split_point = self.data.len - begin_idx;
                mem.copy(T, data[0..split_point], self.data[begin_idx..self.data.len]);
                mem.copy(T, data[split_point..pop_len], self.data[0..end_idx]);
            }

            self.last += pop_len;

            return data[0..pop_len];
        }
    };
}
