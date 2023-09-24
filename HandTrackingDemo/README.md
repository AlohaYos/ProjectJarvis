# HandTrackFake
Simulate hand tracking movements in order to debug hand tracking on visionOS simulator.  
You no longer need real VisionPro device to test your spatial gestures.
This module uses VNHumanHandPoseObservation on Mac/iPhone to capture finger movement.  
And send that hand tracking data to visionOS simulator on Mac via bluetooth.  
All you need is Mac (additionally iPhone/iPad as TrackingSender) to debug visionOS hand tracking.  
  
- Aug/30/2023: Now TrackingSender works on Mac Catalyst using mac front camera.  

## HandTrackFake module
HandTrackFake.swift
```swift
// Public properties
var enableFake = true
var rotateHands = false
var sessionState: MCSessionState = .notConnected
```

## Sample project
### TrackingSender
 - Capture your hand movement using Mac (or iPhone/iPad) front camera.
 - Encode hand tracking data (2D) into Json.
 - Send that Json to TrackingReceiver.app via bluetooth.

https://github.com/AlohaYos/HandTrackFake/assets/4338056/0e84ad30-c92b-4d01-9118-038805d15345

AppDelegate.swift
```swift
let handTrackFake = HandTrackFake()
```

HandTrackingProvider.swift
```swift
// Activate fake data sender
handTrackFake.initAsAdvertiser()

// Send fake data
handTrackFake.sendHandTrackData(handJoints2D)
```

Info.plist
```
Privacy - Camera Usage Description
Privacy - Local Network Usage Description  
Bonjour services  
 - item 0 : _HandTrackFake._tcp  
 - item 1 : _HandTrackFake._udp  
```

### TrackingReceiver
 - Receive hand tracking data (Json) from TrackingSender.app via bluetooth.
 - Decode Json data into hand tracking data (3D).
 - Display hands (finger positions) on visionOS simulator display.

https://github.com/AlohaYos/HandTrackFake/assets/4338056/b7e648ef-9f74-4e36-b17c-6057d46702f9

TrackingReceiverApp.swift
```swift
let handTrackFake = HandTrackFake()
```

ImmersiveView.swift
```swift
// Activate fake data browser
handTrackFake.initAsBrowser()

// Check connection status
let nowState = handTrackFake.sessionState
```

HandTrackProcess.swift
```swift
// Receive 2D-->3D converted hand tracking data
let handJoint3D = handTrackFake.receiveHandTrackData()
```

Info.plist
```
Privacy - Local Network Usage Description  
Bonjour services  
 - item 0 : _HandTrackFake._tcp  
 - item 1 : _HandTrackFake._udp  
```

