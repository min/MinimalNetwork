# MinimalNetwork

MinimalNetwork is a simple HTTP library for iOS 5+.

## Features

* Simple block based interface for asynchronous network requests.
* Throttle the number of concurrent networks calls.
* Ability to apply custom parse logic in a background thread.
* UIImageView category to asynchronously load external images.
* ARC enabled.

## Example

### HTTP GET

``` objective-c

NSString *maybe = @"555-5555";

MN_GET(@"http://call/me/%@", maybe).
  parse((id)^(id data) {
    // background thread
    return [self customParser:data];
  }).
  success(^(MNURLRequest *request, id data) {
    [self didFinish:data];
  }).
  failure(^(MNURLRequest *request, NSError *error) {
    [self showError:error]; 
  }).
  send();
  
// or a more traditional syntax

MNURLRequest *request = [MNURLRequest get:@"http://call/me/maybe"];
request.parseBlock = (id)^(id data){
  // background thread
  return [self customParser:data];
};
request.successBlock = ^(MNURLRequest *request, id data){
  [self didFinish:data];
};
request.failureBlock = ^(MNURLRequest *request, NSError *error){
  [self showError:error]; 
};
[request start];

```

### Images

``` objective-c

UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 48.0f, 48.0f)];
[imageView mn_load:@"http://someimage.jpg"];

```