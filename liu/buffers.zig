const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;

pub fn RingBuffer(comptime T: type, comptime len_opt: ?usize) type {
    return struct {
        const Self = @This();

        const Cond = if (len_opt) |len| struct {
            const Buffer = [len]T;
            const Alloc = void;

            fn init() Self {
                return Self{
                    .data = undefined,
                    .alloc = {},

                    .offset = 0,
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

                    .offset = 0,
                    .next = 0,
                    .last = 0,
                };
            }

            fn deinit(self: *Self) void {
                self.alloc.free(self.data);
            }
        };

        data: Cond.Buffer,
        alloc: Cond.Alloc,
        offset: usize,
        next: usize,
        last: usize,

        pub const init = Cond.init;
        pub const deinit = Cond.deinit;

        pub fn pushMany(self: *Self, data: []const T) usize {
            const len = self.next - self.last;

            const push_len = std.math.min(self.data.len - len, data.len);

            var i: usize = 0;
            var idx = self.next % self.data.len;

            while (i < push_len) : (i += 1) {
                self.data[idx] = data[i];

                idx += 1;
                if (idx == self.data.len) {
                    idx = 0;
                }
            }

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
            const len = self.next - self.last;

            const pop_len = std.math.min3(self.data.len, len, data.len);

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

            if (self.last == self.next) {
                self.last = 0;
                self.next = 0;
            }

            return data[0..pop_len];
        }
    };
}
