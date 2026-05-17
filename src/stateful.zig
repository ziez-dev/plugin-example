const std = @import("std");
const ziez = @import("ziez");

/// Stateful plugin example: owns heap resources, freed via Middleware.deinit_fn.
pub const StatefulConfig = struct {
    value: u32 = 0,
};

/// Returns a Middleware that carries state. The state is heap-allocated and
/// freed automatically when the app shuts down (via deinit_fn).
pub fn middleware(config: StatefulConfig) ziez.Middleware {
    const owned = std.heap.page_allocator.create(StatefulConfig) catch @panic("OOM");
    owned.* = config;
    return .{
        .ptr = owned,
        .handler = struct {
            fn run(_: ?*anyopaque, _: *ziez.Request, _: *ziez.Response, next: *ziez.Next) void {
                next.call();
            }
        }.run,
        .deinit_fn = struct {
            fn deinit(ptr: ?*anyopaque, _: std.mem.Allocator) void {
                if (ptr) |p| std.heap.page_allocator.destroy(@as(*StatefulConfig, @ptrCast(@alignCast(p))));
            }
        }.deinit,
    };
}

/// Convenience: registers stateful middleware on the app.
pub fn setup(app: *ziez.App, config: StatefulConfig) void {
    app.use(middleware(config));
}
