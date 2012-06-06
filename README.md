MinimalNetwork
==============

Simple HTTP library for Objective-C

Example
==============

GET
--------------

``` objective-c

GET(@"http://api.dribbble.com/shots/everyone").
  success(^(MNURLRequest *request, id data){
    
  }).
  failure(^(MNURLRequest *request, NSError *error){
    
  }).
  send();

```