set CHRUBY_VERSION '0.3.5'

set -eg RUBIES
test -d "$PREFIX/opt/rubies/"; and set -xg RUBIES $RUBIES "$PREFIX"/opt/rubies/*
test -d "$HOME/.rubies/";      and set -xg RUBIES $RUBIES "$HOME"/.rubies/*

function chruby_reset
  test -z "$RUBY_ROOT"; and return

  for arg in $PATH
    test "$arg" = "$RUBY_ROOT/bin"; and continue

    if test "$UID" != "0"
      test -n "$GEM_HOME"; and test "$arg" = "$GEM_HOME/bin"; and continue
      test -n "$GEM_ROOT"; and test "$arg" = "$GEM_ROOT/bin"; and continue
    end

    set -g NEW_PATH $NEW_PATH $arg
  end

  set PATH $NEW_PATH
  set -eg NEW_PATH

  if test "$UID" != "0"
    for arg in $GEM_PATH
      test "$arg" = "$GEM_HOME"; and continue
      test "$arg" = "$GEM_ROOT"; and continue
      set -g NEW_GEM_PATH $NEW_GEM_PATH $arg
    end

    set -gx GEM_PATH $NEW_GEM_PATH
    set -e NEW_GEM_PATH
    set -e GEM_ROOT
    set -e GEM_HOME
  end

  set -e RUBY_ROOT
  set -e RUBY_ENGINE
  set -e RUBY_VERSION
  set -e RUBY_PATCHLEVEL
  set -e RUBYOPT
  return 0
end

function chruby_use
  echo $argv | read -l ruby_path opts

  if not test -x "$ruby_path/bin/ruby"
    echo "chruby: $ruby_path/bin/ruby not executable" >&2
    return 1
  end

  test -n "$RUBY_ROOT"; and chruby_reset

  set -gx RUBY_ROOT $ruby_path
  set -gx RUBYOPT $opts
  set PATH $RUBY_ROOT/bin $PATH

  set -gx RUBY_ENGINE     (ruby_variable 'RUBY_ENGINE')
  set -gx RUBY_VERSION    (ruby_variable 'RUBY_VERSION')
  set -gx RUBY_PATCHLEVEL (ruby_variable 'RUBY_PATCHLEVEL')
  set -gx GEM_ROOT        (ruby_variable 'Gem.default_dir')

  if test "$UID" != "0"
    if set -gq GEM_ROOT
      set -l gem_root_bin "$GEM_ROOT/bin"
      test -d "$gem_root_bin"; or mkdir -p $gem_root_bin
      set PATH "$GEM_ROOT/bin" $PATH
    end

    set -l gem_home_bin "$HOME/.gem/$RUBY_ENGINE/$RUBY_VERSION/bin"
    test -d $gem_home_bin; or mkdir -p $gem_home_bin

    set -gx GEM_HOME "$HOME/.gem/$RUBY_ENGINE/$RUBY_VERSION"
    set -gx GEM_PATH $GEM_HOME $GEM_ROOT $GEM_PATH
    set PATH "$GEM_HOME/bin" $PATH
  end

  # The following moves the path entry for './bin' (and it's varieties) to the front
  # of PATH so that binstubs are not overridden by the the rubygems install.
  for i in (seq (count $PATH))
    set -l path_entry $PATH[$i]

    if test "$path_entry" = "bin" -o "$path_entry" = "./bin" -o "$path_entry" = "bin/" -o "$path_entry" = "./bin/"
      set -e PATH[$i]
      # Ignore warnings from set if the bin dir doesn't exist in the current directory
      set PATH "$path_entry" $PATH ^/dev/null
      break
    end
  end
end

function ruby_variable
  if test "$argv" = "RUBY_ENGINE"
    eval "$RUBY_ROOT/bin/ruby -e 'begin; require \'rubygems\'; rescue LoadError; end; print defined?(RUBY_ENGINE) ? RUBY_ENGINE : \'ruby\''"
  else if test "$argv" = "Gem.default_dir"
    if test (eval "$RUBY_ROOT/bin/ruby -e 'print defined?(Gem) ? \"0\" : \"1\"'") = "0"
      eval "$RUBY_ROOT/bin/ruby -e 'begin; require \'rubygems\'; rescue LoadError; end; print Gem.default_dir'"
    end
  else
    eval "$RUBY_ROOT/bin/ruby -e 'begin; require \'rubygems\'; rescue LoadError; end; print $argv'"
  end
end

function chruby
  echo $argv | read -l arg
  if test "$arg" = ""
    for dir in $RUBIES
      test "$dir" = "$RUBY_ROOT"; and set star '*'; or set star ' '
      set dir (basename $dir); echo " $star $dir"
    end
    return 0
  end

  switch $argv[1]
    case '-h' '--help'
      echo "usage: chruby [RUBY|VERSION|system] [RUBY_OPTS]"
    case '-v' '--version'
      echo "chruby version $CHRUBY_VERSION"
    case 'system'
      chruby_reset
    case '*'
      echo $argv | read -l ruby opts

      set -l match ''

      for dir in $RUBIES
        switch (basename $dir)
          case "*$ruby*"
            set match "$dir"
        end
      end

      if test -z "$match"
        echo "chruby: unknown Ruby: $ruby" >&2
        return 1
      end

      chruby_use "$match" "$opts"
  end
end
