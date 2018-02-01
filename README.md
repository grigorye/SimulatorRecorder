[![](https://travis-ci.org/grigorye/SimulatorRecorder.svg?branch=master)](https://travis-ci.org/grigorye/SimulatorRecorder)

# SimulatorRecorder

Record (compressed) Simulator video with a keypress.

## Requirements

These are limitations of the current version.

* [Brewed](https://brew.sh) ffmpeg, jq (in `~/homebrew/bin`)

## HOWTO

1. Build the project (sorry)
2. Launch the app
3. Command-N
4. Command-.
5. Recording will be revealed in Finder in ~/Simulator Recordings
 
## Defaults
 
### Recordings directory
 
 ```
 defaults write com.grigorye.SimulatorRecorder customRecordingsDir ~/var/"Simulator Recordings"
 ```
 
### File names

```
defaults write com.grigorye.SimulatorRecorder videoNameCommand 'date +%Y-%m-%d'
```
