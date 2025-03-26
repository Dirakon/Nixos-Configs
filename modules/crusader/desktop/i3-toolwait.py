#!/usr/bin/env -S python3 -B
# Taken from here:
# https://gitlab.com/wef/dotfiles/-/blob/master/bin/i3-toolwait
# dependencies: i3ipc: https://i3ipc-python.readthedocs.io/en/latest/

# Copyright (C) 2020-2024 Bob Hepple <bob dot hepple at gmail dot com>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at
# your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# https://www.reddit.com/r/swaywm/comments/ru3rn9/a_feeble_version_of_toolwait_to_start_a_session/
# https://www.reddit.com/r/swaywm/comments/skpcmo/method_for_starting_applications_on_startup_on/

from i3ipc import Connection
import argparse
import subprocess, os, sys
import time
from multiprocessing import Process

sys.dont_write_bytecode = True

global parser, i3, retval, args, start_time, count

def verbose(msg):
    if args.verbose:
        elapsed_time = time.time() - start_time
        sys.stderr.write(f"{elapsed_time}s: {parser.prog}: {msg}\n")

def sleep_and_run_command():
    "This runs in a separate process"
    s = 0.1 # just enough to let i3ipc.main() loop start
    verbose(f"Runner process sleeping for {s}s")
    time.sleep(s)
    verbose(f"Running: {args.command}")
    subprocess.Popen(args.command, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def on_window(i3, e):
    "callback function from i3ipc.main() loop"

    # note: I thought of adding an option to also allow a wait on the
    # 'name' field (ie the window title) but at the time of this
    # event, it has not been populated!!

    global count

    verbose(f"Got a {e.change} window event:")
    container = e.ipc_data['container']
    try:
        verbose(f"app_id: {container['app_id']}")
    except:
        verbose(f"Class: {container['window_properties']['class']}, instance: {container['window_properties']['instance']}")

    waitfor = args.command[0]
    if args.waitfor:
        waitfor = args.waitfor

    finished = False
    if args.nocheck:
        finished = True
    else:
        new_window = container['app_id'] or container['window_properties']['instance']
        if waitfor in new_window:
            # eg pavucontrol sometimes comes up as org.pulseaudio.pavucontrol
            verbose(f"a new window for '{waitfor}' appeared")
            count -= 1
            if count <= 0:
                finished = True
                args.id = container['id']
        else:
            verbose(f"a new window appeared '{new_window}' but I'm waiting for '{waitfor}'")

    if finished:
        i3.main_quit() # else continue to wait

if __name__ == "__main__":

    msg = "i3-msg"
    wm = "i3"
    if os.getenv("SWAYSOCK") != "":
        msg = "swaymsg"
        wm = "sway"

    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
        description="""
Run 'command', wait for a window to open, then exit. If no window
appears in 'timeout' seconds (eg by running a non-GUI program like
'date') then terminate.
""",
        epilog=f"""eg.

    %(prog)s firefox # this gives time for the window to be created before:
    {msg} -q "floating disable; border none"

To run more complex commands use "--". eg.

    %(prog)s -- bash -c "some complex bash commands"

This may be similar to the ancient Sun OpenWindows command toolwait or
the X11 version at
http://www.ibiblio.org/pub/linux/X11/xutils/toolwait-0.9.tar.gz
    """)
    parser.add_argument('-n', '--nocheck', dest='nocheck', action='store_true',
                        help='don\'t check that the window that opens is for that command (default = %(default)s)')
    parser.add_argument('-v', '--verbose', dest='verbose', action='store_true', help='verbose operation')
    parser.add_argument('-m', '--mark', dest='mark', type=str, help='mark to add to window', default='')
    parser.add_argument('-t', '--timeout', dest='timeout', type=float, help='timeout (default = %(default)s secs)', default=30.0)
    parser.add_argument('-w', '--waitfor', dest='waitfor', help='app_id (wayland) or instance string (xwayland) to wait for (default is the program name)')
    parser.add_argument('-c', '--count', dest='count', type=int, help='number of windows to wait for (default 1)', default=1)
    parser.add_argument('command', nargs='+', help='command to run')
    args = parser.parse_args()
    args.id = 0

    i3 = Connection()
    i3.on('window::new', on_window)

    retval = 1
    start_time = time.time()
    count = args.count

    # run the command without waiting ie in background:
    Process(target=sleep_and_run_command, daemon=True).start()
    i3.main(timeout=args.timeout)

    # i3ipc gives no indication that a timeout has occured, so check the clock:
    elapsed_time = time.time() - start_time
    if elapsed_time <= args.timeout:
        verbose(f"'{args.command} took {elapsed_time}secs to create its first window")
        retval = 0
    else:
        verbose(f"timed out after {args.timeout} secs")

    if args.mark != '':
        mark_cmd = f'{msg} -q mark "{args.mark}"'
        verbose(f"Running: {mark_cmd}")
        subprocess.run(mark_cmd, shell=True)

    verbose(f"terminating, retval={retval}")
    print(args.id)
    sys.exit(retval)
