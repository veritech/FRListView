FRListView
==========

What
-----
FRListView is a replacement for UITableView. Built from the ground up using UIScrollView as it's parent.
It accepts regular UITableViewCell's. The only real key feature is it supports sticking to the bottom, useful for chat apps ;).

It doesn't support insertion and deletion animations (there is only so much time in a day).

Why
----
Yeah, i ask myself that all the time. This was created as a solution to a problem that wasn't actually a problem...

 Yeah one of those.

How
---
It works just like a UITableView, however the delegate and datasource methods have be slightly altered to protect the innocent.
It also uses regular integer based indexes rather than NSIndexPath objects, and as a result only supports a single section.

License
-------
Copyright (C) 2011 by Float-Right Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

Contact
-------
Jonathan Dalrymple [Twitter](http://twitter.com/veritech) 