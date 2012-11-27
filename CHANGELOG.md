## master ##

## 1.2.6 ##

* Fix missing submit button on new ticket form on iPad

## 1.2.5 ##

* Fix a couple of bugs related to data not refreshing after sign-in
* Add Dutch translation (thanks to nvh)
* Add support for setting external_ids on the user, for integrations
* Reload everything whenever the SDK is launched (previously we were caching data until the host app was unloaded)
* Remove warning about unconfirmed email

## 1.2.4 ##

* Add support for setting custom fields programmatically
* Add support for armv7s (iPhone 5)

## 1.2.3 ##

* Fix a bug that would cause sign-in to fail when connected to a private forum
* Remove some dead code

## 1.2.2 ##

* Fix a bug with table headers on iOS 4.3
* Fix a bug with table borders on iPad / iOS 4.3
* Show correct version number on about screen
* Simplify loading sequence
* Fix a bug with customizing the color of table view section headers
* Add Traditional Chinese translation (thanks to zetachang)
* Fix a bug where API calls were being made with malformed URLs

## 1.2.1 ##

* Track instant answers for analytics
* Add Italian translation (thanks to Piero87)

## 1.2.0 ##

* Add top articles and suggestions to welcome screen
* Make ordering of suggestions match feedback site default (Hot Ideas, New Ideas, or Top Ideas)
* Add instant answers to contact form
* Fix a bug where it appeared you could vote on declined ideas
* Add support for helpdesk-only accounts

## 1.1.1 ##

* Remove sign out button if the user is signed in programmatically
* Fix a cosmetic issue with custom fields on the iPad

## 1.1.0 ##

* Display error messages from API
* Update installation instructions
* Remove 'Leave a Rating' feature
* Remove footer from all views except welcome view
* Remove footer shadow
* Remove disclosure indicator from "Load more ideas" row
* Remove unused images
* Hide "Done" button when searching or creating suggestions
* Remove sign in message for voting
* Move add suggestion row to top of search results
* Move email/name fields below category on new suggestion view
* Back out to the welcome screen after creating a suggestion
* No longer require a user to log in to submit a ticket
* Remove subject field from contact form
* Automatically focus on text area on contact form
* Fix behavior of new suggestion link on contact form
* Fix behavior of new ticket link on new suggestion form
* Add a cancel button to loading screen for those on slow connections
* Add a method to go directly to the contact form
* Add localization support
* Add French translation (thanks to @netbe)
* Move keyboard done button to the right side on Contact Us and Suggestion forms
* Add a method to go directly to the feedback forum
* Refactor public interface
* Redesign about screen
* Add support for custom fields on contact form
* Add the ability to change the navigation bar tint color using a custom stylesheet

## 1.0.3 ##

* Fix a bug where the network connection image would be stretched in an unsightly way

## 1.0.2 ##

* Fix a bug where the number of available votes didn't get updated on user login or signup

## 1.0.1 ##

* Fix a bug with the suggestion form when there aren't any categories

## 1.0.0 ##

* First supported release
* Add (basic) iPad support
* Add landscape support
* Fix a number of bugs
* Switch to static library for distribution
* Add stylesheet support
