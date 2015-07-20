fcpm-ruby
=========

fcpm-ruby is a wrapper for bundler which caches precompiled versions of
gems. The goal is to provide a faster deployment experience.


Usage
-----

Specify the location of the remote cache of precompiled gems:

    echo http://fcpm.example.com/cache > .fcpm-ruby-config

Invoke `bin/fcpm-ruby` as if it were bundler:

    bin/fcpm-ruby install

For even faster installs, tell bundler/fcpm-ruby to use multiple jobs:

    bin/fcpm-ruby install --jobs=8


