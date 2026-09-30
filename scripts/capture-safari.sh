#!/usr/bin/env bash
set -euo pipefail

TARGET_URL="${1:?Usage: capture-safari.sh URL OUTPUT_DIR}"
OUTPUT_DIR="${2:?Usage: capture-safari.sh URL OUTPUT_DIR}"
mkdir -p "$OUTPUT_DIR"

case "$TARGET_URL" in
  https://*|http://127.0.0.1:4173/*) ;;
  *) echo '::error::Csak HTTPS URL vagy a helyi probaoldal hasznalhato.'; exit 1 ;;
esac

if ! xcrun simctl list devicetypes | grep -Fq 'iPhone 14 ('; then
  echo '::error::Az iPhone 14 Simulator típus nem érhető el ezen a GitHub Mac gépen.'
  xcrun simctl list devicetypes
  exit 1
fi

SIM_RUNTIME='com.apple.CoreSimulator.SimRuntime.iOS-18-6'
if ! xcrun simctl list runtimes | grep -Fq "$SIM_RUNTIME"; then
  echo '::error::Az iOS 18.6 Simulator runtime nem érhető el ezen a GitHub Mac gépen.'
  xcrun simctl list runtimes
  exit 1
fi

DEVICE_ID="$(xcrun simctl create 'IPHONE Safari QA' 'iPhone 14' "$SIM_RUNTIME")"
trap 'xcrun simctl shutdown "$DEVICE_ID" >/dev/null 2>&1 || true; xcrun simctl delete "$DEVICE_ID" >/dev/null 2>&1 || true' EXIT
xcrun simctl boot "$DEVICE_ID"
xcrun simctl bootstatus "$DEVICE_ID" -b
xcrun simctl launch "$DEVICE_ID" com.apple.mobilesafari >/dev/null
xcrun simctl openurl "$DEVICE_ID" "$TARGET_URL"
sleep 5
xcrun simctl io "$DEVICE_ID" screenshot "$OUTPUT_DIR/screenshot.png"

export TARGET_URL OUTPUT_DIR SIM_RUNTIME
python3 - <<'PY'
import json
import os
import subprocess
from pathlib import Path

report = {
    'device': 'iPhone 14 Simulator',
    'runtime': os.environ['SIM_RUNTIME'],
    'url': os.environ['TARGET_URL'],
    'screenshot': 'screenshot.png',
    'runtimes': subprocess.check_output(['xcrun', 'simctl', 'list', 'runtimes'], text=True).strip(),
    'note': 'Safari runs on an iOS Simulator, not a physical iPhone.'
}
Path(os.environ['OUTPUT_DIR'], 'report.json').write_text(
    json.dumps(report, ensure_ascii=False, indent=2) + '\n', encoding='utf-8'
)
PY
