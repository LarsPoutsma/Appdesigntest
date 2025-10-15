#!/bin/bash
set -euo pipefail
if ! command -v flutter >/dev/null; then
  echo "Flutter SDK not found" >&2
  exit 1
fi
flutter pub get
flutter run -d macos --dart-define=SUPABASE_URL=${SUPABASE_URL:-} --dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY:-}
