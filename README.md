# ChatSecure-Push-iOS
The iOS SDK for [ChatSecure-Push-Server](https://github.com/ChatSecure/ChatSecure-Push-Server).

## Getting Started

### Install
```ruby
pod 'ChatSecure-Push-iOS', :git => 'https://github.com/ChatSecure/ChatSecure-Push-iOS'
```

### Usage

### 1. Setup
If it's the first launch and there is no account.
```swift
let client = Client(baseUrl: NSURL(string: urlString)!, urlSessionConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration(), account: nil)
```
Or if you already have an account. You'll need to store the `username` and `token` to make API requests.
```swfit
let client = Client(baseUrl: NSURL(string: urlString)!, urlSessionConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration(), account: account)
```

### 2. Create account
```swift
client.registerNewUser(username, password: password, email: nil, completion: { (account, error) -> Void in
  //Save account here
  })
```

### 3. Register new device
In order to register a new device first get an APNS token.

```swift
var settings = UIUserNotificationSettings(forTypes: (UIUserNotificationType.Badge | UIUserNotificationType.Sound | UIUserNotificationType.Alert), categories: nil)
application.registerUserNotificationSettings(settings)
```
Once you've recieved the token in the `AppDelegate`.

```swift
self.client.registerDevice(apnsToken, name: "New device name", deviceID: nil, completion: { (device, error) -> Void in
  //Save device here
  })
```

### 4. Get whitelist token to hand out to a friend
```swift
self.client.createToken(apnsToken, name: "New token", completion: { (token, error) -> Void in
  //Save and send to friend
})
```

### 5. Send a push message to a friend

Once you receive a `token` from a friend you can send them a push message.

`data` needs to be a dictionary that is serializable to JSON.

```swift
var message = Message(token: token, data: nil)
self.client.sendMessage(message, completion: { (msg, error) -> Void in
  println("Message: \(msg)")
  })
```
