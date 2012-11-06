Overview
--------

(This documentation is for the master, or work-in-progress, version of the SDK.)

The UserVoice iOS SDK allows you to embed UserVoice directly in your iOS app.
You will need to have a UserVoice account for it to connect to.

Binary builds of the SDK are available [for download](https://github.com/uservoice/uservoice-iphone-sdk/downloads).

We also have an [example app](https://github.com/uservoice/uservoice-iphone-example) on GitHub that demonstrates how to build and integrate the SDK.

Installation
------------

* Download the latest build.
* Drag `UVHeaders`, `UVResources`, and `libUserVoice.a` into your project.
* Note that the `.h` files in  `UVHeaders` do not need to be added to your target.
* Add QuartzCore and SystemConfiguration frameworks to your project.
* Add `-ObjC` to `Other Linker Flags` in the Build Settings for your target. (There is also an `Other Linker Flags` setting for your entire project, but that's not the one you want.)

See [DEV.md](https://github.com/uservoice/uservoice-iphone-sdk/blob/master/DEV.md) if you want to build the SDK yourself.

Obtain Key And Secret
---------------------

* Go to the admin section of your UserVoice account and click `Channels` under `Settings`.
* Add an iOS App.
* Copy the generated `Secret` and `API key`.

API
---

Once you have completed these steps, you are ready to launch the UserVoice UI
from your code. Import `UserVoice.h` and create a `UVConfig` using one of the
following options.

#### Configuration

**1. Standard Login:** This is the most basic option, which will allow users to
either sign in, or create a UserVoice account, from inside the UserVoice UI.
This is ideal if your app does not have any information about the user.

    UVConfig *config = [UVConfig configWithSite:@"YOUR_USERVOICE_URL"
                                         andKey:@"YOUR_KEY"
                                      andSecret:@"YOUR_SECRET"];

**2. SSO for local users:** This will find or create a new user by passing a
name, email, and unique id. However, it will only find users that were
previously created using this method. It will not allow you to log the user in
as an existing UserVoice account. This is ideal if you only want to use
UserVoice with your iOS app.

    UVConfig *config = [UVConfig configWithSite:@"YOUR_USERVOICE_URL"
                                         andKey:@"YOUR_KEY"
                                      andSecret:@"YOUR_SECRET"
                                       andEmail:@"USER_EMAIL"
                                 andDisplayName:@"USER_DISPLAY_NAME"
                                        andGUID:@"GUID"];

**3. UserVoice SSO:** This is the most flexible option. It allows you to log
the user in using a UserVoice SSO token. This is ideal if you are planning to
use single signon with UserVoice across multiple platforms. We recommend you
encrypt the token on your servers and pass it to the iOS app.

    UVConfig *config = [UVConfig configWithSite:@"YOUR_USERVOICE_URL"
                                         andKey:@"YOUR_KEY"
                                      andSecret:@"YOUR_SECRET",
                                    andSSOToken:@"SOME_BIG_LONG_SSO_TOKEN"];

### Custom Fields

You can set custom field values on the `UVConfig` object. These will be used
associated with any tickets the user creates during their session. You can
also use this to set default values for custom fields on the contact form.

    config.customFields = [NSDictionary dictionaryWithObjectsAndKeys:@"Value", @"Key", nil];


### Invocation

Then you will want to launch UserVoice from the appropriate place in your code.
There are 3 options here as well:

**1. Standard UserVoice Interface:** The user can browse suggestions, leave
comments, etc. This is the full experience of everything the SDK can do
    
    [UserVoice presentUserVoiceInterfaceForParentViewController:self andConfig:config];

**2. Direct link to contact form:** Launches the regular UI, but forwards the user
directly to the contact form.

    [UserVoice presentUserVoiceContactUsFormForParentViewController:self andConfig:config];
    
**3. Direct link to feedback forum:** Launches the regular UI, but forwards the
user directly to the forum screen.

    [UserVoice presentUserVoiceForumForParentViewController:self andConfig:config];


Feedback
--------

You can share feedback on the [UserVoice iOS SDK forum](http://feedback.uservoice.com/forums/64519-iphone-sdk-feedback).


Translations
------------

Currently the UI is available in English, French, Italian, and Traditional Chinese.
We are using [Twine](https://github.com/mobiata/twine) to manage the translations.

To contribute to the translations, follow these steps:

* Fork the project on Github
* Edit the `strings.txt` file
* Commit your changes and open a pull request

If you want to go the extra mile and test your translations, do the following:

* If you are adding a language:
  * `mkdir Resources/YOURLOCALE.lproj`
  * `touch Resources/YOURLOCALE.lproj/UserVoice.strings`
* Install the `twine` gem
* Run `./strings.sh` to generate the strings files
* Run the example app (or your own app) to see how things look in the UI
* Make note of any layout issues in your pull request so that we can look at it
  and figure out what to do.

Some strings that show up in the SDK come directly from the UserVoice API. If a
translation is missing for a string that does not appear in the SDK codebase,
you will need to contribute to the main [UserVoice translation
site](http://translate.uservoice.com/).


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
