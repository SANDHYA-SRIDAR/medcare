#!/usr/bin/env bash
set -euo pipefail

FLUTTER_ROOT="$HOME/flutter"

if [ ! -x "$FLUTTER_ROOT/bin/flutter" ]; then
  echo "Installing Flutter SDK..."
  git clone https://github.com/flutter/flutter.git --depth 1 --branch stable "$FLUTTER_ROOT"
fi

export PATH="$FLUTTER_ROOT/bin:$PATH"

flutter --version
flutter config --enable-web
flutter pub get
flutter build web --release --base-href /