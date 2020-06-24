# iCloud Shared Folder Issue

## Lab
Developer Technical Support Open Hours

## The Issue
The NSDocument may intermittently reload with older data than was last saved, when storing an NSDocument in a iCloud Drive shared folder. This happens without any other device editing concurrently.

## Reproduce
- Create an iCloud Drive shared folder on a different AppleID
- Open and Run the attached sample project
- The attached sample project uses a text field which reads/stores a String as an NSDocument
- The attached sample project shows a list of log entries indicating what data was written and read by AppKit and when FileCoordination happens
- The attached sample project shows the NSDocument.lastModifiedDate
- Start typing into the the textfield and occasionally hit CMD+S (Save). 

## Expected
NSDocument should never read older data than what was last saved
The file modification date should remain as last saved.

## Actual
Sometimes the TextField reverts to a previous state
In the log you see that there can be sequences where after Writing a certain Text to disk, a bit later an older state is read from disk. This is after filecoordination relinquished to a writer (probably icloud deamon). Then, a second or so later it reads again and then has the current data again. 
The file modification dates known by the NSDocument are also changed, dates get their milliseconds truncated after file coordination.

## System
Tested on macOS 10.15.5
