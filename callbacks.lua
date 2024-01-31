--
-- 中文:
-- 该枚举对应的lua函数
-- 在 fas-rs 中将被 fas-rs 回调
-- pub enum CallBacks {
--  LoadFas(pid_t), --------> function load_fas(pid)
--  UnloadFas(pid_t), ------> function unload_fas(pid)
--  StartFas, --------------> function start_fas()
--  StopFas, ---------------> function stop_fas()
--  InitCpuFreq, -----------> function init_cpu_freq()
--  WriteCpuFreq(usize), ---> function write_cpu_freq(freq)
--  ResetCpuFreq, ----------> function reset_cpu_freq()
-- }
--
-- 可注册的函数说明:
-- function load_fas(pid)
-- 当 fas-rs 加载到目标游戏时调用，
-- 参数为目标应用程序的pid。
--
-- function unload_fas(pid)
-- 当 fas-rs 卸载到目标游戏时调用，
-- 参数为目标应用程序的pid。
--
-- function start_fas()
-- 切换到fas-rs工作状态时调用。
--
-- function stop_fas()
-- 切换到 fas-rs 不工作状态时调用。
--
-- function init_cpu_freq()
-- 当cpu控制器进入控制状态时调用。
--
-- function write_cpu_freq(freq)
-- 当cpu控制器写入cpu频率时调用，
-- 参数是正在写入的频率。
--
-- function reset_cpu_freq()
-- 当cpu控制器退出控制状态时调用。
--
-- 附加: 在函数外的lua代码会在插件加载时被执行，
-- 如果你有执行初始化内容的需求，这样做很方便。
--
-- fas-rs提供的函数:
-- log_info("message")
-- 打印一个info等级日志到/sdcard/Android/fas-rs/fas_log.txt
--
-- log_error("message")
-- 打印一个error等级日志到/sdcard/Android/fas-rs/fas_log.txt
--
-- log_debug("message")
-- 打印一个debug等级日志到/sdcard/Android/fas-rs/fas_log.txt，
-- 此等级在fas-rs的release build不开启
--
-- ------------------------------------
--
-- EN:
-- The lua function corresponding to this enumeration
-- in fas-rs will be called back by fas-rs
-- pub enum CallBacks {
--  LoadFas(pid_t), --------> function load_fas(pid)
--  UnloadFas(pid_t), ------> function unload_fas(pid)
--  StartFas, --------------> function start_fas()
--  StopFas, ---------------> function stop_fas()
--  InitCpuFreq, -----------> function init_cpu_freq()
--  WriteCpuFreq(usize), ---> function write_cpu_freq(freq)
--  ResetCpuFreq, ----------> function reset_cpu_freq()
-- }
--
-- Registerable function description:
-- function load_fas(pid)
-- Called when fas-rs is loaded into the target game,
-- the parameter is the pid of the target application.
--
-- function unload_fas(pid)
-- Called when fas-rs is unloaded into the target game,
-- the parameter is the pid of the target application.
--
-- function start_fas()
-- Called when switching to fas-rs working state.
--
-- function stop_fas()
-- Called when switching to fas-rs not-working state.
--
-- function init_cpu_freq()
-- Called when the cpu controller enters the control state.
--
-- function write_cpu_freq(freq)
-- Called when the cpu controller writes the cpu frequency,
-- the parameter is the frequency being written.
-- 
-- function reset_cpu_freq()
-- Called when the cpu controller exits the control state.
--
-- Extra: Lua code outside the function will be
-- executed when the extension is loaded, if you need to
-- execute initialization content, this is convenient.
--
-- Functions provided by fas-rs:
-- log_info("message")
-- Print an info level log to /sdcard/Android/fas-rs/fas_log.txt
--
-- log_error("message")
-- Print an error level log to /sdcard/Android/fas-rs/fas_log.txt
--
-- log_debug("message")
-- Print a debug level log to /sdcard/Android/fas-rs/fas_log.txt,
-- This level is not enabled in the release build of fas-rs.
--
function init()
    local freqs = io.open("/sys/devices/system/cpu/cpufreq/policy0/scaling_available_frequencies", "r")
    max_freq_0 = freqs:read("n*")

    while (true) do
        local freq = freqs:read("n*")
        if (freq ~= nil) then
            min_freq_0 = freq
        else
            freqs:close()
            break
        end
    end

    local freqs = io.open("/sys/devices/system/cpu/cpufreq/policy4/scaling_available_frequencies", "r")
    max_freq_4 = freqs:read("n*")

    while (true) do
        local freq = freqs:read("n*")
        if (freq ~= nil) then
            min_freq_4 = freq
        else
            freqs:close()
            break
        end
    end

    local freqs = io.open("/sys/devices/system/cpu/cpufreq/policy7/scaling_available_frequencies", "r")
    max_freq_7 = freqs:read("n*")

    while (true) do
        local freq = freqs:read("n*")
        if (freq ~= nil) then
            min_freq_7 = freq
        else
            freqs:close()
            break
        end
    end
end

function bound(freq)
    io.open("/proc/cpudvfs/cpufreq_debug", "w"):write(string.format("0 %d %d", min_freq_0, freq)):close()
    io.open("/proc/cpudvfs/cpufreq_debug", "w"):write(string.format("4 %d %d", min_freq_4, freq)):close()
    io.open("/proc/cpudvfs/cpufreq_debug", "w"):write(string.format("7 %d %d", min_freq_7, freq)):close()
end

function reset()
    io.open("/proc/cpudvfs/cpufreq_debug", "w"):write(string.format("0 %d %d", min_freq_0, max_freq_0)):close()
    io.open("/proc/cpudvfs/cpufreq_debug", "w"):write(string.format("4 %d %d", min_freq_4, max_freq_4)):close()
    io.open("/proc/cpudvfs/cpufreq_debug", "w"):write(string.format("7 %d %d", min_freq_7, max_freq_7)):close()
end

function set_governor()
    io.open("/sys/devices/system/cpu/cpufreq/policy0/scaling_governor", "w"):write("sugov_ext"):close()
    io.open("/sys/devices/system/cpu/cpufreq/policy4/scaling_governor", "w"):write("schedutil"):close()
    io.open("/sys/devices/system/cpu/cpufreq/policy7/scaling_governor", "w"):write("schedutil"):close()
end

init()
reset()
set_governor()

function init_cpu_freq()
    pcall(reset)
end

function reset_cpu_freq()
    pcall(reset)
    pcall(set_governor)
end

function write_cpu_freq(freq)
    pcall(bound, freq)
end
