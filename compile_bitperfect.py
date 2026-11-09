"""Compile the rebuilt SS13 40.87.1 source with BYOND 341 and make the .dmb equal the original, byte for byte.

Put this file in the same folder as the BYOND 341 dreammaker.exe (or pass --byond) and run:

    python compile_bitperfect.py PATH\\TO\\cellautomata.dme

The argument can also be the folder holding the .dme. Without it the script looks in the current folder, then in its own folder.
Needs only Python 3 on Windows, nothing else. Starts Dream Maker minimized as a normal program: no debugger, no patches, no registry changes.

As with Dream Maker, cellautomata.dmb and cellautomata.rsc end up next to the .dme, replacing any there. They are written only once a
compile matches: each try runs in a temporary copy, so a failed run leaves your files as they were.

The one byte fix: two bytes of the .dmb (offset 744628, world record +37, the hub_password id) are uninitialised memory in the compiler.
The 2004 original holds dc ff there, left over from that compile; Dream Maker today writes 00 00 or random bytes, almost never dc ff.
So after a compile this script writes dc ff into those two bytes, and only then checks the md5 of the whole file. Every other byte
comes from the compiler. A compile that already gave dc ff by itself is reported as such.

Exit code: 0 = bit-perfect copy made, 1 = no match within --tries, 2 = setup or compile problem."""
import argparse, ctypes, ctypes.wintypes as W, hashlib, os, shutil, subprocess, sys, tempfile, time

WANT_MD5 = 'c22c4e53a081a3dc864bbe1c7920c4f2'
WANT_SIZE = 744867
FIELD = 744628
FIELD_VALUE = b'\xdc\xff'
NAME = 'cellautomata'
WM_COMMAND, WM_GETTEXT, WM_GETTEXTLENGTH = 0x111, 0x0D, 0x0E
SMTO_ABORTIFHUNG = 2

u32 = ctypes.WinDLL('user32', use_last_error=True)
ENUM = ctypes.WINFUNCTYPE(W.BOOL, W.HWND, W.LPARAM)
u32.EnumWindows.argtypes = [ENUM, W.LPARAM]
u32.EnumChildWindows.argtypes = [W.HWND, ENUM, W.LPARAM]
u32.GetWindowThreadProcessId.argtypes = [W.HWND, ctypes.POINTER(W.DWORD)]
u32.IsWindowVisible.argtypes = [W.HWND]
u32.GetClassNameW.argtypes = [W.HWND, W.LPWSTR, ctypes.c_int]
u32.GetMenu.argtypes = [W.HWND]; u32.GetMenu.restype = W.HMENU
u32.GetSubMenu.argtypes = [W.HMENU, ctypes.c_int]; u32.GetSubMenu.restype = W.HMENU
u32.GetMenuItemCount.argtypes = [W.HMENU]
u32.GetMenuItemID.argtypes = [W.HMENU, ctypes.c_int]; u32.GetMenuItemID.restype = ctypes.c_uint
u32.GetMenuStringW.argtypes = [W.HMENU, ctypes.c_uint, W.LPWSTR, ctypes.c_int, ctypes.c_uint]
u32.PostMessageW.argtypes = [W.HWND, ctypes.c_uint, W.WPARAM, W.LPARAM]
u32.SendMessageTimeoutW.argtypes = [W.HWND, ctypes.c_uint, W.WPARAM, ctypes.c_void_p, ctypes.c_uint, ctypes.c_uint, ctypes.POINTER(ctypes.c_size_t)]
u32.SendMessageTimeoutW.restype = ctypes.c_size_t


def windows_of(pid):
    out = []
    def cb(h, _):
        p = W.DWORD(); u32.GetWindowThreadProcessId(h, ctypes.byref(p))
        if p.value == pid and u32.IsWindowVisible(h): out.append(h)
        return True
    u32.EnumWindows(ENUM(cb), 0)
    return out

def compile_command(menu):
    """id of the Compile menu item"""
    for i in range(u32.GetMenuItemCount(menu)):
        b = ctypes.create_unicode_buffer(256); u32.GetMenuStringW(menu, i, b, 256, 0x400)
        mid = u32.GetMenuItemID(menu, i)
        if mid == 0xffffffff:
            sub = u32.GetSubMenu(menu, i)
            found = compile_command(sub) if sub else None
            if found is not None: return found
        elif b.value.replace('&', '').lower().startswith('compile'):
            return mid
    return None

def send_text(h, msg, wp, buf):
    r = ctypes.c_size_t()
    ok = u32.SendMessageTimeoutW(h, msg, wp, buf, SMTO_ABORTIFHUNG, 1000, ctypes.byref(r))
    return r.value if ok else 0

def output_pane(main):
    """text of Dream Maker's output pane; only read when a compile gave no .dmb"""
    found = []
    def cb(c, _):
        name = ctypes.create_unicode_buffer(64); u32.GetClassNameW(c, name, 64)
        if name.value == 'RICHEDIT':
            n = send_text(c, WM_GETTEXTLENGTH, 0, None)
            if n:
                b = ctypes.create_unicode_buffer(n + 1); send_text(c, WM_GETTEXT, n + 1, ctypes.cast(b, ctypes.c_void_p)); found.append(b.value)
        return True
    u32.EnumChildWindows(main, ENUM(cb), 0)
    return found[0].replace('\r\n', '\n').strip() if found else ''

def md5(path):
    with open(path, 'rb') as f: return hashlib.md5(f.read()).hexdigest()

def field(path):
    with open(path, 'rb') as f:
        f.seek(FIELD); return f.read(2).hex()

def compile_once(exe, dme, timeout):
    """-> (status, text). status: ok, exited, nowindow, nomenu, timeout. Looks only at the file system while compiling."""
    dmb = dme[:-4] + '.dmb'
    if os.path.exists(dmb): os.remove(dmb)
    si = subprocess.STARTUPINFO(); si.dwFlags = subprocess.STARTF_USESHOWWINDOW; si.wShowWindow = 7     # minimized, no focus
    p = subprocess.Popen([exe, dme], cwd=os.path.dirname(dme), startupinfo=si)
    try:
        main = None
        for _ in range(120):
            time.sleep(0.25)
            if p.poll() is not None: return 'exited', 'Dream Maker closed by itself, code 0x%08x' % (p.returncode & 0xffffffff)
            main = next((h for h in windows_of(p.pid) if u32.GetMenu(h)), None)
            if main: break
        if not main: return 'nowindow', 'Dream Maker opened no main window'
        time.sleep(1)
        cmd = compile_command(u32.GetMenu(main))
        if cmd is None: return 'nomenu', 'no Compile command in the Dream Maker menu'
        u32.PostMessageW(main, WM_COMMAND, cmd, 0)
        end = time.time() + timeout; size = -1; same = 0
        while time.time() < end:
            time.sleep(0.25)
            if p.poll() is not None: return 'exited', 'Dream Maker closed during the compile, code 0x%08x' % (p.returncode & 0xffffffff)
            now = os.path.getsize(dmb) if os.path.exists(dmb) else -1
            same = same + 1 if now == size and now > 0 else 0
            size = now
            if same >= 4: return 'ok', ''           # unchanged for a second
        return 'timeout', output_pane(main)
    finally:
        if p.poll() is None:
            p.kill(); p.wait(5)

def find_source(arg, here):
    """folder holding the .dme; arg = the .dme itself, its folder, or nothing"""
    if arg and arg.lower().endswith('.dme'): arg = os.path.dirname(os.path.abspath(arg))
    for d in ([arg] if arg else [os.getcwd(), here]):
        if os.path.exists(os.path.join(d, NAME + '.dme')): return os.path.abspath(d)
    return None

def main():
    here = os.path.dirname(os.path.abspath(__file__))
    a = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    a.add_argument('source', nargs='?', help='%s.dme or the folder holding it' % NAME)
    a.add_argument('--byond', default=here, help='folder holding dreammaker.exe (default: the folder of this script)')
    a.add_argument('--out', help='where the matching .dmb and .rsc go (default: next to the .dme)')
    a.add_argument('--tries', type=int, default=20)
    a.add_argument('--timeout', type=int, default=60, help='seconds for one compile')
    o = a.parse_args()
    exe = os.path.join(os.path.abspath(o.byond), 'dreammaker.exe')
    if not os.path.exists(exe):
        print('no dreammaker.exe in %s. Put this script next to it, or use --byond FOLDER.' % os.path.dirname(exe)); return 2
    src = find_source(o.source, here)
    if not src:
        print('no %s.dme found. Pass it: python compile_bitperfect.py PATH\\TO\\%s.dme' % (NAME, NAME)); return 2
    out = os.path.abspath(o.out or src)
    build = tempfile.mkdtemp(prefix='ss13_', dir=None)
    print('compiler %s\nsource   %s' % (exe, src), flush=True)
    try:
        work = os.path.join(build, 'b')
        shutil.copytree(src, work, ignore=shutil.ignore_patterns('*.dmb', '*.rsc', '*.lk', '*.int', '*.py'))
        dme = os.path.join(work, NAME + '.dme'); dmb = dme[:-4] + '.dmb'
        for i in range(1, o.tries + 1):
            t = time.time()
            st, txt = compile_once(exe, dme, o.timeout)
            if st != 'ok':
                print('try %d: %s' % (i, st), flush=True)
                if txt: print(txt[-600:], flush=True)
                if st == 'timeout' and ' error' in txt and ' 0 errors' not in txt: return 2     # real compile errors
                if st in ('nomenu', 'exited') and i >= 3: return 2
                continue
            size = os.path.getsize(dmb)
            if size != WANT_SIZE:
                print('try %d: the .dmb has %d bytes, the original %d: this is not the matching source' % (i, size, WANT_SIZE)); return 2
            got = field(dmb)
            with open(dmb, 'r+b') as f:
                f.seek(FIELD); f.write(FIELD_VALUE)
            if md5(dmb) == WANT_MD5:
                os.makedirs(out, exist_ok=True)
                for ext in ('.dmb', '.rsc'):
                    if os.path.exists(dme[:-4] + ext): shutil.copy2(dme[:-4] + ext, out)
                how = 'the compiler wrote %s itself' % got if got == FIELD_VALUE.hex() else 'compiler wrote %s there, set to %s' % (got, FIELD_VALUE.hex())
                print('try %d: BIT-PERFECT, md5 %s, %.0f s (bytes at %d: %s)\n%s'
                      % (i, WANT_MD5, time.time() - t, FIELD, how, os.path.join(out, NAME + '.dmb')))
                return 0
            print('try %d: the .dmb differs from the original beyond the 2 bytes at %d, compiling again' % (i, FIELD), flush=True)
        print('no match in %d tries' % o.tries)
        return 1
    finally:
        shutil.rmtree(build, ignore_errors=True)

if __name__ == '__main__':
    sys.exit(main())
