#see: http://stackoverflow.com/questions/6438116/rails-with-ruby-debugger-throw-symbol-not-found-ruby-current-thread-loaderro

export PATCH_LEVEL=`ruby -e 'puts RUBY_PATCHLEVEL'`
export RVM_SRC=$HOME/.rvm/rubies/ruby-1.9.3-p$PATCH_LEVEL/include/ruby-1.9.1
gem install archive-tar-minitar
gem install ruby_core_source -- --with-ruby-include=/$RVM_SRC
export RVM_SRC=$HOME/.rvm/rubies/ruby-1.9.3-p$PATCH_LEVEL/include/ruby-1.9.1/ruby-1.9.3-p$PATCH_LEVEL

wget http://rubyforge.org/frs/download.php/75415/ruby-debug-base19-0.11.26.gem
wget http://rubyforge.org/frs/download.php/63094/ruby-debug19-0.11.6.gem
wget http://rubyforge.org/frs/download.php/75414/linecache19-0.5.13.gem
gem install linecache19-0.5.13.gem -- --with-ruby-include=/$RVM_SRC
# if that step failed, and you are running OSX Lion, then following this post can help you: 
# http://stackoverflow.com/questions/8032824/cant-install-ruby-under-lion-with-rvm-gcc-issues
# this happens if you recently installed xcode from the app store. 
# bizarrely, for me I had to do this: ln -s /usr/bin/gcc /usr/bin/gcc-4.2
gem install ruby-debug-base19-0.11.26.gem -- --with-ruby-include=/$RVM_SRC

