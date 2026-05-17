const std = @import("std");
const my_plugin = @import("ziez_my_plugin");

test "Config defaults" {
    const config = my_plugin.Config{};
    try std.testing.expect(config.enabled == true);
}

test "middleware returns valid Middleware" {
    const mw = my_plugin.middleware(.{});
    try std.testing.expect(mw.ptr == null);
    try std.testing.expect(mw.deinit_fn == null);
}

test "stateful middleware returns valid Middleware" {
    const mw = my_plugin.stateful.middleware(.{ .value = 42 });
    try std.testing.expect(mw.ptr != null);
    try std.testing.expect(mw.deinit_fn != null);
}
