Overview
--------

The UserVoice iOS SDK allows you to embed UserVoice directly in your iOS app.
You will need to have a UserVoice account for it to connect to.

Binary builds of the SDK are available [for download](https://github.com/uservoice/uservoice-iphone-sdk/downloads).

We also have an [example app](https://github.com/uservoice/uservoice-iphone-example) on GitHub that demonstrates how to build and integrate the SDK.

Installation
------------

* Download the latest build.
* Drag `UVHeadeers`, `UVResources`, and `libUserVoice.a` into your project.
* Note that the `.h` files in  `UVHeaders` do not need to be added to your target.

See [DEV.md](https://github.com/uservoice/uservoice-iphone-sdk/blob/master/DEV.md) if you want to build the SDK yourself.

Obtain Key And Secret
---------------------

* Go to the admin section of your UserVoice account and click `Channels` under `Settings`.
* Add an iOS App.
* Copy the generated `Secret` and `API key`.

API
---

Once you have completed these steps, you are ready to launch the UserVoice UI
from your code. Import `UserVoice.h` and call one of the three methods on the
UserVoice class.

**1. Standard Login:** This is the most basic option, which will allow users to
either sign in, or create a UserVoice account, from inside the UserVoice UI.
This is ideal if your app does not have any information about the user.

    [UserVoice presentUserVoiceModalViewControllerForParent:self
                                                    andSite:@"YOUR_USERVOICE_URL"
                                                     andKey:@"YOUR_KEY"
                                                  andSecret:@"YOUR_SECRET"];

**2. SSO for local users:** This will find or create a new user by passing a
name, email, and unique id. However, it will only find users that were
previously created using this method. It will not allow you to log the user in
as an existing UserVoice account. This is ideal if you only want to use
UserVoice with your iOS app.

    [UserVoice presentUserVoiceModalViewControllerForParent:self
                                                    andSite:@"YOUR_USERVOICE_URL"
                                                     andKey:@"YOUR_KEY"
                                                  andSecret:@"YOUR_SECRET"
                                                   andEmail:@"USER_EMAIL"
                                             andDisplayName:@"USER_DISPLAY_NAME"
                                                    andGUID:@"GUID"];

**3. UserVoice SSO:** This is the most flexible option. It allows you to log
the user in using a UserVoice SSO token. This is ideal if you are planning to
use single signon with UserVoice across multiple platforms. We recommend you
encrypt the token on your servers and pass it to the iOS app.

    [UserVoice presentUserVoiceModalViewControllerForParent:self
                                                    andSite:@"YOUR_USERVOICE_URL"
                                                     andKey:@"YOUR_KEY"
                                                  andSecret:@"YOUR_SECRET",
                                                andSSOToken:@"SOME_BIG_LONG_SSO_TOKEN"];

Feedback
--------

You can share feedback on the [UserVoice iOS SDK forum](http://feedback.uservoice.com/forums/64519-iphone-sdk-feedback).

License
-------

Copyright 2010 UserVoice Inc. 

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
