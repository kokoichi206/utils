## HOW TO USE
[setup.sh](setup.sh) is the main file.

``` sh
$ curl -s https://raw.githubusercontent.com/kokoichi206/utils/main/golang/setup.sh -o setup.sh && bash setup.sh

# when you need to customize the settings
$ curl -s https://raw.githubusercontent.com/kokoichi206/utils/main/golang/setup.sh -o setup.sh
$ bash setup.sh [OPTIONs]
```

### github actions
- example: [ci.yml](ci.yml)
	- test with postgresql service
