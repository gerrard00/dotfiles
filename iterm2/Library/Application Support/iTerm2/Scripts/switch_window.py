#!/usr/bin/env python3.7

# modified version of: https://iterm2.com/python-api/examples/movetab.html#movetab-example

import iterm2
from pprint import pprint

#!/usr/bin/env python3.7
import iterm2

async def main(connection):
    app = await iterm2.async_get_app(connection)

    async def activate_relative_window(delta):
        current_window = app.current_window
        current_window_index = app.terminal_windows.index(current_window)
        n = len(app.terminal_windows)
        j = (i + delta) % n
        if i == j:
            return
        target_window = app.terminal_windows[j]
        await target_window.async_activate()

    @iterm2.RPC
    async def activate_next_window():
        await activate_relative_window(1)
    await activate_next_window.async_register(connection)

    @iterm2.RPC
    async def activate_previous_window():
        n = len(app.terminal_windows)
        if n > 0:
            await activate_relative_window(n - 1)
    await activate_previous_window.async_register(connection)

iterm2.run_forever(main)
