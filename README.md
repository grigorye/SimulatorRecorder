[![](https://travis-ci.org/grigorye/SimulatorRecorder.svg?branch=master)](https://travis-ci.org/grigorye/SimulatorRecorder)
[![](https://gitlab.com/grigorye/SimulatorRecorder/badges/master/pipeline.svg)](https://gitlab.com/grigorye/SimulatorRecorder/commits/master)

# SimulatorRecorder

Record (compressed) Simulator video with a keypress.

## HOWTO

1. Install the [latest build of the app](https://gitlab.com/grigorye/SimulatorRecorder/-/jobs/artifacts/master/raw/build/SimulatorRecorder.pkg?job=build_project)
2. Launch the app
3. Allow the app to control your computer in Privacy > Accessibility (once)
4. Press Command-Shift-5 to start recording
5. Press Command-Shift-5 to stop recording
6. Recording will be revealed in Finder in ~/Simulator Recordings

See 'Simulator Recorder' > Preferences for stuff like shanging hot key and etc.
 

## Third Parties Used

### Bundled

* [FFmpeg](https://ffmpeg.org)
* [jq](https://stedolan.github.io/jq)

### Frameworks

* [MASShortcut](https://github.com/shpakovski/MASShortcut)

### Build-time only

* [Homebrew](https://brew.sh)

## Build Requirements

* Xcode 10
