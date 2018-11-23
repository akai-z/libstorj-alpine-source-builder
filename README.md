# Libstorj Alpine Source Builder

## What is Libstorj?

Asynchronous multi-platform C library and CLI for encrypted file transfer on the Storj network.

**Note: The library is deprecated.**

([Click here to know more about Libstorj](https://github.com/storj/libstorj))


## What is Storj?

Storj is a platform, token, and suite of decentralized applications that allows you to store data in a secure and decentralized manner.

Check the following links to know more about Storj:  
https://storj.io/  
https://github.com/storj/storj


## Usage

```
libstorj-alpine-source-builder.sh [OPTIONS]

  clean
    Removes library source and temporary files, and "build" dependencies.
    (If used, the library source build function will be ignored.)

  run_deps_install
    Installs library "run" dependencies.
    (If used, the library source build function will be ignored.)

  build_deps_list
    Lists "build" dependencies.

  run_deps_list
    Lists "run" dependencies.

  -build_deps_install
    Enables "build" dependencies installation before building the library.

  -build_deps_delete
    Enables "build" dependencies deletion during clean process.
    (If used, it must be added before clean option.)
    (e.g. libstorj-alpine-source-builder.sh -build_deps_delete clean)

  --repository
    Github repository name. (Optional)

  --version
    Library version. (Optional)
```

## Authors

* Ammar K.

## License

[GNU General Public License version 2](LICENSE)
