#!/system/bin/sh
#
# Copyright 2023 shadow3aaa@gitbub.com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
if [ "$(getprop fas-rs-installed)" = "" ]; then
	ui_print "Please install fas-rs first"
	ui_print "请先安装fas-rs再安装此插件"
	abort
elif cat /sys/devices/soc0/soc_id | grep -iqv MT6895; then
    ui_print "非mt6895设备"
    abort
fi
