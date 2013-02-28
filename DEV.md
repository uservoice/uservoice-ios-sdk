Distribution
------------

To build for distribution, simply run `./build.sh`. It will create a fat binary
for i386 & armv7, copy over the necessary resources, and make a tarball.

Development
-----------

Follow these instructions to set up the SDK for development alongside an iOS
project. See the `dev` branch of the example project for an example of this
setup using a submodule to manage the SDK.

* Run XCode 4.2+
* Have your project inside an XCode workspace
* Download the SDK and drag it into your workspace (or check it out using a git submodule)
* Add `libUserVoice.a` under the `Link Binary With Libraries` build phase
* Set `User Heading Search Paths` to `$(BUILD_PRODUCTS_DIR)`
* Set `Always Search User Paths` to `Yes`
* Add `-ObjC` to `Other Linker Flags`
* Drag the `Include` group from the SDK into your project
  * `Create groups for any added subfolders` should be selected
  * Uncheck any targets
  * You may want to rename the group something like `UVHeaders`
* Drag the `Resources` group from the SDK into your project
  * `Create groups for any added subfolders` should be selected
  * Add to your target
  * You may want to rename the group something like `UVResources`

