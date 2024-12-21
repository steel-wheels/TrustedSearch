# TrustedSearch

## Introduction
This application helps  you to search by Google. 
The features of this application are:
* This application gives the <strong>trusted web site list</strong>
to limit the search targets.
It helps you to find correct infomation from the reliable websites.
* You can give the [google search options](Documents/search-option.md) by GUI. 

## What is the trusted site
This application has the list of trusted web sites.
The definitions of the trusted web site is
* Provide primary information (the source information) or good article about the primary source
* Politically neutral
* Not an affiliate site

The trusted web site list is managed by human modelator.

## Copyright
Copyright (C) 2024 [Steel Wheels Project](https://github.com/steel-wheels/Project).
This software is distributed under [GNU GENERAL PUBLIC LISENCE version 2](https://github.com/steel-wheels/TrustedSearch?tab=GPL-2.0-1-ov-file).

## Target system
* OS version:   macOS 13, iOS 16
* Xcode:        Xcode 14

## Documents
* [Google search parameters](Documents/search-option.md)

## Trusted site list
<pre>
[
  {
    category:	"Company",
    tags: [
	"car"
    ],
    sites: [
	"https://www.isuzu.co.jp",
	"https://www.global-kawasaki-motors.com",
	"https://www.globalsuzuki.com",
	"https://www.subaru.co.jp",
	"https://www.daihatsu.com/jp/",
	"https://global.toyota/jp/",
	"https://www.nissan-global.com/JP/",
	"https://www.hino.co.jp",
	"https://global.honda/jp/",
	"https://www.mazda.com/ja/",
	"https://www.mitsubishi-motors.com/jp/",
	"https://www.mitsubishi-fuso.com/ja/",
	"https://global.yamaha-motor.com/jp/",
	"https://www.udtrucks.com/japan"
    ]
  },
  {
    category:	"News",
    tags: [
	"news"
    ],
    sites: [
	"https://www.bbc.com",
	"https://www.cnn.com",
	"https://www.nikkei.com",
	"https://www.data.jma.go.jp/multi/index.html"
    ]
  },
  {
    category:	"Software Development",
    tags: [
	"macOS", "iOS", "Apple"
    ],
    sites: [
	"https://developer.apple.com/"
    ]
  },
  {
    category:	"Software Development",
    tags: [
	"macOS", "iOS", "Unix"
    ],
    sites: [
	"https://github.com",
	"https://qiita.com",
	"https://news.ycombinator.com",
	"https://medium.com"
    ]
  },
  {
    category:	"Software Development",
    tags: [
	"typescript", "language"
    ],
    sites: [
	"https://basarat.gitbook.io/typescript",
	"https://typescript-jp.gitbook.io/deep-dive"
    ]
  },
  {
    category:	"Weather",
    tags: [
	"weather report"
    ],
    sites: [
	"https://tenki.jp"
    ]
  },
  {
    category:	"Wikipedia",
    tags: [],
    sites: [
	"https://ja.wikipedia.org/",
	"https://en.wikipedia.org/",
	"https://de.wikipedia.org/",
	"https://fr.wikipedia.org/"
    ]
  }
]


</pre>

# Related links
* [Steel Wheels Project](https://github.com/steel-wheels/Project)



