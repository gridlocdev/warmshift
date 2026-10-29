# WarmShift — menu bar app built with SwiftPM + Xcode's toolchain (no .xcodeproj).

app := "build/WarmShift.app"

default:
    @just --list

# Compile (debug) with Xcode's Swift toolchain
build:
    xcrun swift build

# Run the schedule unit tests
test:
    xcrun swift test

# Build the .app bundle (debug|release)
bundle config="release":
    scripts/bundle.sh {{config}}

# Build a debug bundle and launch it
run: (bundle "debug")
    pkill -x WarmShift || true
    open "{{app}}"

# Launch the bundle with logs in this terminal
run-attached: (bundle "debug")
    pkill -x WarmShift || true
    "{{app}}/Contents/MacOS/WarmShift"

# Install a release build to ~/Applications
install: (bundle "release")
    pkill -x WarmShift || true
    mkdir -p ~/Applications
    rm -rf ~/Applications/WarmShift.app
    cp -R "{{app}}" ~/Applications/
    open ~/Applications/WarmShift.app
    @echo "Installed ~/Applications/WarmShift.app"

# Regenerate Resources/icon.icns from assets/icon.svg (needs Inkscape)
icons:
    scripts/make-icons.sh

# Format sources with swift-format (ships with Xcode)
fmt:
    xcrun swift-format format --in-place --recursive Sources Tests

clean:
    rm -rf .build build
