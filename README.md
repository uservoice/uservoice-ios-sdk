Overview
========

IMPORTANT: The UserVoice iPhone SDK is currently in beta, if you wish to try it out please visit this url to request access:

http://www.uservoice.com/iphone

The UserVoice iPhone SDK is distributed as a XCode Project which you can use to build static libraries to compile against. 

This distribution concept is well described in this post:

http://www.clintharris.net/2009/iphone-app-shared-libraries/

In order to embed the UserVoice functionality into your own iPhone app, you need to perform the following steps:

1. Have a UserVoice account!
2. Clone the SDK from GitHub (or download the zip)
3. Add the SDK to your project (a simple drag'n'drop followed by updating a few settings)
4. Add the UserVoice resources
5. Register your iPhone app on the UserVoice website
6. Add an '#import' and a single line of code where you want to invoke the UserVoice functionality

The instructions below describe this process in more detail.


Instructions
============

Thanks to Johan Williams for this blog post (made my life a lot easier):

http://blog.carbonfive.com/2011/04/04/using-open-source-static-libraries-in-xcode-4/

NB. THESE INSTRUCTIONS ONLY APPLY TO XCODE-4 (Last checked on 4.2), FOR XCODE-3 PLEASE CHECK OUT THE XCODE3 BRANCH AND README

Adding the SDK to your project 
------------------------------

* Either create a new workspace and add your existing project, or just go to the file menu and save your existing project as a workspace.
* Right click on the workspace's navigator and select "Add files to myworkspace" then navigate to the UserVoiceSDK project and select the UserVoice.xcodeproj file, this should create a secondary project in the workspace.


Update Build Settings
---------------------

* Select your app’s build target and go to the “Link Binary With Libraries” build phase.
* Click add and select the UserVoice.a library from the Workspace dropdown
* Locate the “User Header Search Paths” setting. Set this to “$(BUILT_PRODUCTS_DIR)”

* Look for Other Linker Flags.
* Double-click, then add "-ObjC".
* Double-click, then add "-all_load".


Add Resources
-------------

* Create a group called UVResources
* Right-click on UVResources, then choose Add -> Existing Files.
* Select the "UserVoice/Resources" folder. In the dialog, leave "Copy items..." unchecked and then click Add.
* Right-click on your project and choose Add -> Existing Files.
* Select the Categories folder from the UserVoiceSDK directory. In the dialog, leave "Copy items..." unchecked and then click Add.


Obtain Key And Secret
---------------------

* Go to the admin section of your UserVoice account and click 'Apps & Plugins'.
* Click on the iPhone tab and click create.
* Make a note of your key and secret and of your forum URL.


Import UserVoiceSDK
-------------------

* Add the following import statement to the class that is responsible for launching the UserVoice view (probably a view controller):


    #import "UserVoice.h"
	

Invoke UserVoice View - Standard Login
--------------------------------------

* In your view controller, where you want to invoke the UserVoice view (probably from a button action), use the following code:


    [UserVoice presentUserVoiceModalViewControllerForParent:self
                                                    andSite:@"YOUR_USERVOICE_URL"
                                                     andKey:@"YOUR_KEY"
                                                  andSecret:@"YOUR_SECRET"];

												  
Invoke UserVoice View - SSO With Existing Users
-----------------------------------------------

* In your view controller, where you want to invoke the UserVoice view (probably from a button action), use the following code:


    [UserVoice presentUserVoiceModalViewControllerForParent:self
                                                    andSite:@"YOUR_USERVOICE_URL"
                                                     andKey:@"YOUR_KEY"
                                                  andSecret:@"YOUR_SECRET",
                                                andSSOToken:@"SOME_BIG_LONG_SSO_TOKEN"];


Invoke UserVoice View - SSO With New Users Only
-----------------------------------------------
												  
* In your view controller, where you want to invoke the UserVoice view (probably from a button action), use the following code:


    [UserVoice presentUserVoiceModalViewControllerForParent:self
                                                    andSite:@"YOUR_USERVOICE_URL"
                                                     andKey:@"YOUR_KEY"
                                                  andSecret:@"YOUR_SECRET"
                                                   andEmail:@"USER_EMAIL"
                                             andDisplayName:@"USER_DISPLAY_NAME"
                                                    andGUID:@"GUID"];


Feedback
--------

We are also using this great service for feedback, UserVoice....

http://feedback.uservoice.com/forums/64519-iphone-sdk-feedback

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


TODO
----

## performance

* Cache more info (client config?) to improve initial load time

## functionality

* Facebook and Google auth support
* Add resend email confirmation functionality

## appearance

* Info button image is being cropped
* Still some text cropping on descenders

## architecture

* Always store the token and just use type to figure out if its request or access
