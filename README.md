# FlickrGeoStream

Written using Swift 4 and Xcode 9.

## Some notes

* Using geo-regions to track movement of the phone does not work on all coniditions. High speeds seem to avoid triggering any leaving event when using a small radius (like 100m). Try selecting "Freeway Drive" in the simulator to reproduce this problem.

* There is not enough error handling towards the user. E.g. no error is displayed when the user does not give permission to use the gps.

* Although the code is organised in a way that writing units should be easy, I did not write any tests to keep it somewhat in the two hour limit.

* The way images are currently fetchted from Flickr does return a lot of duplicates. There is currently no functionality to not display any duplicates.

* Refreshing the UI is not done very good. Instead of just adding a single image to the top, the complete list is updated
