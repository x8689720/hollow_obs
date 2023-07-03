local obs = obslua
local bit = require("bit")
local ffi = require("ffi")
local obsffi = ffi.load("obs")
local u32 = ffi.load("user32.dll")

local hwnd = nil
local invert = 1

local jitter_range             = 6
local game_fps                 = 144
local jitter_enable            = false


local image = "data:image/png;base64,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"

ffi.cdef[[
    typedef void *HANDLE;
    typedef HANDLE HWND;
    typedef HANDLE HICON;
    typedef HICON HCURSOR;
    typedef char CHAR;
    typedef const CHAR *LPCCH,*PCSTR,*LPCSTR;
    typedef int WINBOOL,*PWINBOOL,*LPWINBOOL;
    typedef WINBOOL BOOL;
    typedef long LONG;
    typedef unsigned short WORD, SHORT;
    typedef unsigned long DWORD;
    typedef unsigned long ULONG_PTR;

    typedef struct tagPOINT {
        LONG x;
        LONG y;
    } POINT, *PPOINT, *NPPOINT, *LPPOINT;

    typedef struct tagCURSORINFO {
        DWORD   cbSize;
        DWORD   flags;
        HCURSOR hCursor;
        POINT   ptScreenPos;
    } CURSORINFO, *PCURSORINFO, *LPCURSORINFO;

    HWND FindWindowA(LPCSTR lpClassName, LPCSTR lpWindowName);
    HWND GetForegroundWindow();
    BOOL IsWindow(HWND hWnd);
    BOOL GetCursorInfo(PCURSORINFO pci);
    SHORT GetAsyncKeyState(int vKey);
    void mouse_event(DWORD dwFlags, DWORD dx, DWORD dy, DWORD dwData, ULONG_PTR dwExtraInfo);
    int MessageBoxA(HWND hWnd, LPCSTR lpText, LPCSTR lpCaption, unsigned int uType);
]]

function WinActive(hwnd)
    if ffi.C.GetForegroundWindow() == hwnd then
        return true
    else
        return false
    end
end

function IsCursorShowing()
    local pci = ffi.new("CURSORINFO")
    pci.cbSize = ffi.sizeof("CURSORINFO")
    if ffi.C.GetCursorInfo(pci) ~= 0 then
        return pci.flags ~= 0
    end
end

function jitter_main()
	hwnd = ffi.C.FindWindowA(nil, "Apex Legends")
	if jitter_enable and hwnd and WinActive(hwnd) and not IsCursorShowing() then
		if bit.band(ffi.C.GetAsyncKeyState(0x01), 0x8000) > 0 and bit.band(ffi.C.GetAsyncKeyState(0x02), 0x8000) > 0 then
			ffi.C.mouse_event(0x0001, invert*jitter_range, invert*jitter_range, 0, 0)
			invert = invert * -1
		end
	end
end

function script_description()
    return [[
    <div>
        <h1 style="font-family:Segoe Script; text-align: center">hollow_obs</h1>
        <center><img src=']] .. image .. [['/></center>
    </div>
    <br>
    <div>Apex Legends jitter aimer</div>
    <div><a href="https://github.com/worse-666/hollow_obs" style="float: right">github</a></div>
    <hr>]]
end

function script_properties()
    local props = obs.obs_properties_create()
    obs.obs_properties_add_int_slider(props, "game_fps", "Game FPS", 0, 299, 1)
    obs.obs_properties_add_int_slider(props, "jitter_range", "Range", 0, 100, 1)
    obs.obs_properties_add_bool(props,"jitter_enable", "Enabled")
    return props
end

function script_defaults(settings)
    obs.obs_data_set_default_double(settings, "game_fps", game_fps)
    obs.obs_data_set_default_int(settings, "jitter_range", jitter_range)
    obs.obs_data_set_default_bool(settings, "jitter_enable", jitter_enable)
end

function script_update(settings)
    game_fps = obs.obs_data_get_double(settings, "game_fps")
    jitter_range = obs.obs_data_get_int(settings, "jitter_range")
    jitter_enable = obs.obs_data_get_bool(settings, "jitter_enable")

	if jitter_enable then
        obs.timer_add(jitter_main, math.ceil(1000 / game_fps))
	else
        obs.timer_remove(jitter_main)
	end
end

