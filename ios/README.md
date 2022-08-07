## HOW TO USE

[setup.sh](setup.sh) is the main file.

```sh
$ curl -s https://raw.githubusercontent.com/kokoichi206/utils/main/ios/setup.sh | bash

# when you need to customize the settings
$ curl -s https://raw.githubusercontent.com/kokoichi206/utils/main/ios/setup.sh -o setup.sh
$ bash setup.sh [OPTIONs]
```

### github actions

example: [ci.yml](ci.yml)

### swiftlint

- [script_build_phase_section.txt](./script_build_phase_section.txt)
  - swiftlint のために project.pbxproj に追加が必要なテキストの、3 行目以降。
    - 2 行目にカスタムする項目があるため、1,2 行目はスクリプトで対応。

### semantic versioning

- [version_update.sh](./version_update.sh)
  - バージョンを更新するためのもの。
