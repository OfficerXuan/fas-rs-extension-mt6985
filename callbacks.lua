--
-- Copyright 2023 shadow3aaa@gitbub.com
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
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
