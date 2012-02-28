Node.js port for iOS
===

### To build

Open nios.xcodeproj with your XCode and just Run

### Tests

Tests are not available (yet).

Goal
---

The objective is to run any (or most) node.js apps on any iOS device with no (or very few) modifications.

Approach
---
Nios sends messages from javascript to objective-c (and vice versa) using WebViewJavascriptBridge for asyncronic methods, and syncronic XML HTTP Requests when the result is immediatly needed.
All modules and libraries written for node.js in C++ needs to be ported.
