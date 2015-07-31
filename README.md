fcpm-ruby
=========

fcpm-ruby is a wrapper for bundler which caches precompiled versions of
gems. The goal is to provide a faster deployment experience.


Usage
-----

Invoke `bin/fcpm-ruby` as if it were bundler:

    bin/fcpm-ruby install

For even faster installs, tell `fcpm-ruby` to use multiple jobs:

    bin/fcpm-ruby install --jobs=8


Configuration
-------------

A `.fcpm-ruby-config` file can be used to tell `fcpm-ruby` not only where
to find precompiled gems, but also where to put them if they don't already
exist and need to be rebuilt.

The (YAML-formatted) config file supports these keys:

* `source` -- a URI telling where to look for precompiled gems. This currently
  supports "http://" and "file:" URIs.
* `host` -- a URI telling where gems should be stored if they need to be rebuilt.
  This supports "scp://" and "file:" URIs. (See also `key`, below.)
* `key` -- this is a path to a local SSH key to be used when uploading newly
  built gems via SCP. (See `host`, above.)

A sample config that hosts prebuilt gems locally might might look like this:

    source: file:/path/to/precompiled/gems
    host: file:/path/to/precompiled/gems

On the other hand, a config that hosts prebuilt gems on a different server
might look like this:

    source: http://example.com/path
    host: scp://user@example.com/u/sites/path
    key: /local/path/to/ssh_key

In this case, given a gem like 'rails-5.0.0' on Mac OSX, `fcpm-ruby` will
first look for it at `http://example.com/path/rails-5.0.0-x86_64-darwin-14.tar.gz`.
If found, it is downloaded and installed. Otherwise, the gem itself is downloaded
from a gem server, built locally, and then uploaded to `host` with whatever
credentials that includes, and using the `key` to authenticate with the server.

Authors
-------

Jamis Buck <jamis@jamisbuck.org>
