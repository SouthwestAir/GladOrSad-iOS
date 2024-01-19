fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios DarkSideOfTheMoon

```sh
[bundle exec] fastlane ios DarkSideOfTheMoon
```

Run, rabbit run.

### ios test

```sh
[bundle exec] fastlane ios test
```

Runs tests

### ios build_adhoc

```sh
[bundle exec] fastlane ios build_adhoc
```

Create adhoc build (local)

### ios distribute_firebase

```sh
[bundle exec] fastlane ios distribute_firebase
```

Build and submit to Firebase App Distribution

### ios distribute_testflight

```sh
[bundle exec] fastlane ios distribute_testflight
```

Build and submit to TestFlight

### ios trigger_testflight

```sh
[bundle exec] fastlane ios trigger_testflight
```

Trigger CircleCI to run TestFlight Release job

### ios setup

```sh
[bundle exec] fastlane ios setup
```

Download and install provisioning profiles, certificates, and keys for code signing (adhoc & appstore)

### ios update_match

```sh
[bundle exec] fastlane ios update_match
```

Update or create provisioning profiles, certs, and keys for code signing (adhoc & appstore), and detect new devices.

### ios current_version

```sh
[bundle exec] fastlane ios current_version
```

Show current project version

### ios bump_major

```sh
[bundle exec] fastlane ios bump_major
```

Shortcut to bump major version number

### ios bump_minor

```sh
[bundle exec] fastlane ios bump_minor
```

Shortcut to bump minor version number

### ios bump_patch

```sh
[bundle exec] fastlane ios bump_patch
```

Shortcut to bump patch version number

### ios bump_build

```sh
[bundle exec] fastlane ios bump_build
```

Shortcut to bump build number

### ios upload_to_testflight_swa

```sh
[bundle exec] fastlane ios upload_to_testflight_swa
```

SWA specific TestFlight Configuration for TestFlight Builds

### ios create_new_app

```sh
[bundle exec] fastlane ios create_new_app
```

Configure new app on dev portal, create provisioning profiles

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
