## Seat Geek Coding Exercise
<img src="SeatGeekFavorite.gif" alt="SeatGeekFavorite" height="619" />

---
## Requirements

- [x] Write your application for Native iOS Platform preferably with Swift **(used Storyboards and UIKit)**

- [x] Favorited events are persisted between app launches **(used UserDefaults)**

- [x] Events are searchable through SeatGeek API **(see known issues)**

- [x] Unit tests are preferable **(about 70% coverage)**

- [x] Third party libraries are allowed **(used Reachability by ashleymills, no CocoaPods for install simplicity)**

- [x] Make sure that the application supports iOS 12 and above **(tested on simulator iPhone X iOS 12.1)**

- [x] The application must compile with Xcode 12.x.x **(used Xcode 12.4)**

- [x] Please add a README or equivalent documentation about your project

  [Full requirements document](SeatGeekCodingExercise.pdf)

---
## Installation

1. Clone repo: https://github.com/philmodin/SeatGeekCodingExercise.git
2. Open: `SeatGeekCodingExercise.xcodeproj`
3. Set team and bundle ID.
4. Notice `InfoSeatGeek.plist` is missing. Ignore it and build project, this file will be auto generated.
5. Open `InfoSeatGeek.plist` If you have a client ID for Seat Geek, paste it here. Otherwise register for one at: https://seatgeek.com/account/develop
6. Attach device and run the project.
7. If needed, check trusted apps in iPhone device management settings for your developer profile.

---
## Known issues

- Testing internet reconnection does not work on simulator. See GitHub [issue](https://github.com/ashleymills/Reachability.swift/issues/151).
- Searching events using the `q` arguement produces unexpected results. For example searching "ba" returns less events than "bas" See GitHub [issue](https://github.com/seatgeek/api-support/issues/65).
<img src="SeatGeekSearch.gif" alt="SeatGeekSearch" height="619" />
