#!/usr/bin/env bash
# Runs inside android-emulator-runner after boot. Hands the emulator's adb port to the operator and keeps the
# job alive for LAB_MINUTES. The runner's own adb server is stopped so the tunnelled connection owns the device.
set -u
# Both values are read from the event payload (never interpolated into a command or an env listing) and masked first.
CHISEL_AUTH=$(jq -r '.inputs.tunnel_auth' "$GITHUB_EVENT_PATH")
TUNNEL_URL=$(jq -r '.inputs.tunnel_url' "$GITHUB_EVENT_PATH")
echo "::add-mask::$CHISEL_AUTH"
echo "::add-mask::$TUNNEL_URL"
echo "device: sdk=$(adb shell getprop ro.build.version.sdk | tr -d '\r') abi=$(adb shell getprop ro.product.cpu.abi | tr -d '\r') size=$(adb shell wm size | tr -d '\r')"
adb shell settings put global stay_on_while_plugged_in 7 || true
adb shell svc power stayon true || true
adb kill-server || true
echo "tunnel up for ${LAB_MINUTES} minutes"
timeout "${LAB_MINUTES}m" lab/chisel client --keepalive 20s --auth "$CHISEL_AUTH" "$TUNNEL_URL" \
  R:127.0.0.1:15555:127.0.0.1:5555 2>&1 | grep -v -i "auth\|http" || true
echo "session finished"
