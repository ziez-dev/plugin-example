const std = @import("std");
const ziez = @import("ziez");

pub const stateful = @import("stateful.zig");

/// Example config for this plugin.
pub const Config = struct {
    enabled: bool = true,
};

/// Returns a configured Middleware that can be passed to `app.use()`.
pub fn middleware(config: Config) ziez.Middleware {
    _ = config;
    return .{
        .ptr = null,
        .handler = struct {
            fn run(_: ?*anyopaque, _: *ziez.Request, _: *ziez.Response, next: *ziez.Next) void {
                next.call();
            }
        }.run,
        .deinit_fn = null,
    };
}

/// Convenience: registers this plugin's middleware on the app.
pub fn setup(app: *ziez.App, config: Config) void {
    app.use(middleware(config));
}
