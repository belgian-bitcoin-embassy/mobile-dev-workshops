### git

Since we will be using git to clone the workshop repository to have the same starting point again from time to time, make sure you have git installed on your system.

It is very probable that you already have it installed, but if you don't, you can check by running `git --version` in a terminal. If it is installed a version number will be returned, if not, you will see an error message.

If you don't get a version returned, you can follow the instructions from [git-scm](https://git-scm.com/downloads) or [github](https://github.com/git-guides/install-git) to install it.

### Flutter

The mobile development framework used will be Flutter, as to easily build applications for both Android and iOS and to make use of existing Bitcoin and Lightning libraries.

Following the [official installation instructions](https://flutter.dev/docs/get-started/install), install Flutter for your operating system.

> [!CAUTION]  
> It is important to select iOS or Android when choosing your first type of app. Do **NOT** select Desktop or Web!

The app will be developed to run on both Android and iOS, so if you would like to run the app on both Android and iOS, you will need to install Flutter for both app types. To just run the app during the workshop, it is sufficient to follow the instructions for just one of the two.

Make sure that running `flutter doctor` in a terminal shows no errors, as described in the installation instructions.

### IDE or code editor

The instructor of the workshops will be using [VSCodium](https://vscodium.com/), a free and opensource distribution of [Visual Studio Code](https://code.visualstudio.com/) without Microsoft's telemetry/tracking, so it might be easier to follow along if you use it too, but any IDE or code editor should work.

If you install VSCodium, make sure to also install the [Flutter extension](https://open-vsx.org/extension/Dart-Code/flutter) and [Dart extension](https://open-vsx.org/extension/Dart-Code/dart-code).

---

> [!WARNING]
> The following steps are only required for the first workshop, where a local development network is set up to test the Bitcoin on-chain wallet. If you finished the steps above and will attend the second or third workshop, you are ready to go and can skip the rest of this document.

### Install Polar (and Docker Desktop/Server)

Polar is a Bitcoin and Lightning Network development tool that makes it easy to run a local network of Bitcoin and Lightning test nodes and to interact with them or use them in the development of applications.

Download from https://lightningpolar.com/ and follow the installation instructions for your operating system.

Make sure you have [Docker Desktop](https://www.docker.com/products/docker-desktop) installed on Windows or MacOS and [Docker Server](https://docs.docker.com/engine/install/#server) on Linux, since the Polar app needs Docker to run the nodes.

### Install Rust

Alongside our Bitcoin node in Polar, we will need to run an Electrum server to be able to use the Bitcoin Development Kit (BDK) library. The Electrum server we will use is written in Rust, so we will need to install Rust to be able to run it.

You can use rustup to install Rust, following the instructions on https://rustup.rs/.

### clang, cmake and build-essential (Ubuntu only)

If you are using Ubuntu, also run the following to be able to run the Electrum server:

```bash
$ sudo apt update
$ sudo apt install clang cmake build-essential  # for building 'rust-rocksdb'
```
