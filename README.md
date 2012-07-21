# MinimalNetwork

MinimalNetwork is a simple HTTP library for iOS 5+.

## Features

* Simple block based interface for asynchronous network requests.
* Throttle the number of concurrent networks calls.
* Ability to apply custom parse logic in a background thread.
* UIImageView category to asynchronously load external images.
* ARC enabled.

## Example

### GET

``` objective-c

MN_GET(@"http://call/me/%@", maybe).
  parse(^(id data){
    // background thread
    return [self customParser:data];
  }).
  success(^(MNURLRequest *request, id data){
    // main UI thread
    [self didFinish:data];
  }).
  failure(^(MNURLRequest *request, NSError *error){
    // main UI thread
    [self showError:error]; 
  }).
  send();

```

### Images

``` objective-c

UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 48.0f, 48.0f)];
[imageView mn_load:@"http://someimage.jpg"];

```