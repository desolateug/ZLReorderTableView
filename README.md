# ZLReorderTableView

[![CI Status](https://img.shields.io/travis/zlj/ZLReorderTableView.svg?style=flat)](https://travis-ci.org/zlj/ZLReorderTableView)
[![Version](https://img.shields.io/cocoapods/v/ZLReorderTableView.svg?style=flat)](https://cocoapods.org/pods/ZLReorderTableView)
[![License](https://img.shields.io/cocoapods/l/ZLReorderTableView.svg?style=flat)](https://cocoapods.org/pods/ZLReorderTableView)
[![Platform](https://img.shields.io/cocoapods/p/ZLReorderTableView.svg?style=flat)](https://cocoapods.org/pods/ZLReorderTableView)

## Description
This pod is used to reoder tableview interactively by implements the drag and drop function of cells.

## Installation

ZLReorderTableView is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ZLReorderTableView'
```

## Usage
```objc

self.tableView.enableReorder = YES;
self.tableView.delegate = self;
self.tableView.dataSource = self;

```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Snapshoot
![snapshoot1](https://github.com/desolateug/ZLReorderTableView/blob/master/Example/Snapshoot/snapshoot1.gif)

## License

ZLReorderTableView is available under the MIT license. See the LICENSE file for more info.
