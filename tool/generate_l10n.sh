#!/bin/bash
# Script to generate localization files
# This should be run after flutter pub get

cd "$(dirname "$0")/.."
flutter gen-l10n

