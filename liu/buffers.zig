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

            fn init(initial_size: usize, alloc: Allocator) !Self {
                const data = try alloc.alloc(T, initial_size);

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

        pub fn pushMany(self: *Self, data: []T) usize {
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

            self.next += push_len;

            return push_len;
        }

        pub fn popMany(self: *Self, data: []T) []T {
            const len = self.next - self.last;

            const pop_len = std.math.min(len, data.len);

            var i: usize = 0;
            var idx = self.next % self.data.len;

            while (i < pop_len) : (i += 1) {
                data[i] = self.data[idx];

                idx += 1;
                if (idx == self.data.len) {
                    idx = 0;
                }
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
