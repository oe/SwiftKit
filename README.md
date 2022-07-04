# SwiftXToolkit

A swift package for personal use(updating while my swift skills improving)

available for > macOS12 and > iOS15

## Installation
click menu `File` -> `Add Packages...`, then input `https://github.com/oe/SwiftKit`


## Features

### URLSession in Javascript Fetch style

```swift
let resp = try await HTTPRequest.fetch("http://www.google.com/")
// with text encoding well handled
let html = resp.text()!


struct UserMeta: Decodable {
  var page: Int
  var per_page: Int
  var total: Int
  var total_pages: Int
}

let resp2 = try await HTTPRequest.fetch("https://reqres.in/api/users", .init(qs: ["page": "1", "per_page": "3"]))
let userMeta: UserMeta = try resp2.json()
```


### Color
convert hex int to Color

```swift
let color = Color(hex: 0x123123)
```
