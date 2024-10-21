
Install build dependencies
```
brew install python3 gawk gnu-sed gmp mpfr libmpc isl zlib expat
brew install coreutils flock gcc@14
```

Build and install toolcain
```
make install
```

Install at different location:
```
make INSTALL_PREFIX=<location> install
```

