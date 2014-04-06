[![Build Status](https://travis-ci.org/JeanMertz/chruby-fish.png?branch=master)](https://travis-ci.org/JeanMertz/chruby-fish)

# chruby-fish

Changes the current Ruby.

## Features

* Updates `$PATH`.
  * Also adds RubyGems `bin/` directories to `$PATH`.
* Correctly sets `$GEM_HOME` and `$GEM_PATH`.
  * Users: gems are installed into `~/.gem/$ruby/$version`.
  * Root: gems are installed directly into `/path/to/$ruby/$gemdir`.
* Additionally sets `$RUBY_ROOT`, `$RUBY_ENGINE`, `$RUBY_VERSION` and
  `$GEM_ROOT`.
* Optionally sets `$RUBYOPT` if second argument is given.
* Fuzzy matching of Rubies by name.
* Defaults to the system Ruby.
* Optionally supports auto-switching and the `.ruby-version` file.
* Supports [fish] (see official [chruby] repository for [bash] and [zsh] support).
* Small (~90 LOC).
* Has tests.

## Anti-Features

* Does not hook `cd`.
* Does not install executable shims.
* Does not require Rubies be installed into your home directory.
* Does not automatically switch Rubies by default.
* Does not require write-access to the Ruby directory in order to install gems.

## Install

    wget -O chruby-0.3.5.1.tar.gz https://github.com/JeanMertz/chruby-fish/archive/v0.3.5.1.tar.gz
    tar -xzvf chruby-0.3.5.1.tar.gz
    cd chruby-fish-0.3.5.1/
    sudo make install

### Rubies

#### Manually

Chruby provides detailed instructions for installing additional Rubies:

* [Ruby](https://github.com/postmodern/chruby/wiki/Ruby)
* [JRuby](https://github.com/postmodern/chruby/wiki/JRuby)
* [Rubinius](https://github.com/postmodern/chruby/wiki/Rubinius)

#### ruby-install

You can also use [ruby-install] to install additional Rubies:

Installing to `/opt/rubies` or `~/.rubies`:

    ruby-install ruby
    ruby-install jruby
    ruby-install rubinius

#### ruby-build

You can also use [ruby-build] to install additional Rubies:

Installing to `/opt/rubies`:

    ruby-build 1.9.3-p392 /opt/rubies/ruby-1.9.3-p392
    ruby-build jruby-1.7.3 /opt/rubies/jruby-1.7.3
    ruby-build rbx-2.0.0-rc1 /opt/rubies/rubinius-2.0.0-rc1

## Configuration

Add the following to the `/etc/fish/config.fish` or `~/.config/fish/config.fish`
file:

    . /usr/local/share/chruby/chruby.fish

By default chruby will search for Rubies installed into `/opt/rubies/` or
`~/.rubies/`. For non-standard installation locations, simply set the
`RUBIES` variable by adding the following to the above mentioned
`config.fish` file before you source `chruby.fish`:

    set -xU RUBIES /opt/jruby-1.7.0 $HOME/src/rubinius

### Migrating

If you are migrating from another Ruby manager, set `RUBIES` accordingly:

* [RVM]: `RUBIES=(~/.rvm/rubies/*)`
* [rbenv]: `RUBIES=(~/.rbenv/versions/*)`
* [rbfu]: `RUBIES=(~/.rbfu/rubies/*)`

### Auto-Switching

If you want chruby to auto-switch the current version of Ruby when you `cd`
between your different projects, simply load `auto.sh` in `config.fish`:

    source /usr/local/share/chruby/auto.fish

chruby will check the current and parent directories for a [.ruby-version]
file. Other Ruby switchers also understand this file:
https://gist.github.com/1912050

### Default Ruby

If you wish to set a default Ruby, simply call `chruby` in `config.fish`:

    chruby ruby-1.9

If you have enabled auto-switching, simply create a `.ruby-version` file:

    echo "ruby-1.9" > ~/.ruby-version

## Examples

List available Rubies:

    $ chruby
       ruby-1.9.3-p392
       jruby-1.7.0
       rubinius-2.0.0-rc1

Select a Ruby:

    $ chruby 1.9.3
    $ chruby
     * ruby-1.9.3-p392
       jruby-1.7.0
       rubinius-2.0.0-rc1
    $ echo $PATH
    /home/hal/.gem/ruby/1.9.3/bin:/opt/rubies/ruby-1.9.3-p392/lib/ruby/gems/1.9.1/bin:/opt/rubies/ruby-1.9.3-p392/bin:/usr/lib64/qt-3.3/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/home/hal/bin:/home/hal/bin
    $ gem env
    RubyGems Environment:
      - RUBYGEMS VERSION: 1.8.23
      - RUBY VERSION: 1.9.3 (2013-02-22 patchlevel 392) [x86_64-linux]
      - INSTALLATION DIRECTORY: /home/hal/.gem/ruby/1.9.3
      - RUBY EXECUTABLE: /opt/rubies/ruby-1.9.3-p392/bin/ruby
      - EXECUTABLE DIRECTORY: /home/hal/.gem/ruby/1.9.3/bin
      - RUBYGEMS PLATFORMS:
        - ruby
        - x86_64-linux
      - GEM PATHS:
         - /home/hal/.gem/ruby/1.9.3
         - /opt/rubies/ruby-1.9.3-p392/lib/ruby/gems/1.9.1
      - GEM CONFIGURATION:
         - :update_sources => true
         - :verbose => true
         - :benchmark => false
         - :backtrace => false
         - :bulk_threshold => 1000
         - "gem" => "--no-rdoc"
      - REMOTE SOURCES:
         - http://rubygems.org/

Switch to JRuby in 1.9 mode:

    $ chruby jruby --1.9
    $ ruby -v
    jruby 1.7.0 (1.9.3p203) 2012-10-22 ff1ebbe on OpenJDK 64-Bit Server VM 1.7.0_09-icedtea-mockbuild_2012_10_17_15_53-b00 [linux-amd64]

Switch back to system Ruby:

    $ chruby system
    $ echo $PATH
    /usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/hal/bin

Run a command under a Ruby with `chruby-exec`:

    $ chruby-exec jruby -- gem update

Switch to an arbitrary Ruby on the fly:

    $ chruby_use /path/to/ruby

## Alternatives

* [RVM]
* [rbenv]
* [rbfu]*
* [ry]
* [ruby-version]*

\* *Deprecated in favor of chruby.*

## Endorsements

> yeah `chruby` is nice, does the limited thing of switching really good,
> the only hope it never grows

-- [Michal Papis](https://twitter.com/mpapis/status/258049391791841280) of [RVM]

> I just looooove [chruby](#readme) For the first time I'm in total control of
> all aspects of my Ruby installation.

-- [Marius Mathiesen](https://twitter.com/zmalltalker/status/271192206268829696)

> Written by Postmodern, it's basically the simplest possible thing that can
> work.

-- [Steve Klabnik](http://blog.steveklabnik.com/posts/2012-12-13-getting-started-with-chruby)

> I wrote ruby-version; however, chruby is already what ruby-version wanted to
> be. I've deprecated ruby-version in favor of chruby.

-- [Wil Moore III](https://github.com/wilmoore)

## Credits

* [mpapis](https://github.com/mpapis) for reviewing the code.
* [havenn](https://github.com/havenwood) for handling the homebrew formula.
* `#bash`, `#zsh`, `#machomebrew` for answering all my questions.

[wiki]: https://github.com/postmodern/chruby/wiki

[chruby]: https://github.com/postmodern/chruby
[bash]: http://www.gnu.org/software/bash/
[zsh]: http://www.zsh.org/
[fish]: http://fishshell.com/
[PGP]: http://en.wikipedia.org/wiki/Pretty_Good_Privacy
[homebrew]: http://mxcl.github.com/homebrew/
[AUR]: https://aur.archlinux.org/packages/chruby/
[FreeBSD ports collection]: https://www.freshports.org/devel/chruby/
[ruby-install]: https://github.com/postmodern/ruby-install#readme
[ruby-build]: https://github.com/sstephenson/ruby-build#readme
[.ruby-version]: https://gist.github.com/1912050

[RVM]: https://rvm.io/
[rbenv]: https://github.com/sstephenson/rbenv#readme
[rbfu]: https://github.com/hmans/rbfu#readme
[ry]: https://github.com/jayferd/ry#readme
[ruby-version]: https://github.com/wilmoore/ruby-version#readme

[Ruby]: http://www.ruby-lang.org/en/
[JRuby]: http://jruby.org/
[Rubinius]: http://rubini.us/
