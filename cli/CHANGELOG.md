# Changelog

## [1.4.0](https://github.com/redfieldchristabel/laravel-dockerize/compare/v1.3.0...v1.4.0) (2026-03-31)


### Features

* upgrade node image version from 18 to 22 in docker-compose template ([41a0163](https://github.com/redfieldchristabel/laravel-dockerize/commit/41a0163de5043a49582f8971d4502bf19e3c6c01))

## [1.3.0](https://github.com/redfieldchristabel/laravel-dockerize/compare/v1.2.2...v1.3.0) (2026-03-31)


### Features

* implement `GitignoreService` to manage `.gitignore` updates ([e0a57e5](https://github.com/redfieldchristabel/laravel-dockerize/commit/e0a57e501bcea47853fb4ed8e45ad0f99cfb1113))

## [1.2.2](https://github.com/redfieldchristabel/laravel-dockerize/compare/v1.2.1...v1.2.2) (2026-03-31)


### Bug Fixes

* move nginx handlers to include directory and add websocket support ([7ef37b2](https://github.com/redfieldchristabel/laravel-dockerize/commit/7ef37b2a31ae99dee5d9a0dd4447e16cb2d4d815))

## [1.2.1](https://github.com/redfieldchristabel/laravel-dockerize/compare/v1.2.0...v1.2.1) (2026-03-30)


### Bug Fixes

* abstract tool generation into a helper method and set generated … ([5964ada](https://github.com/redfieldchristabel/laravel-dockerize/commit/5964adad2616154645583f4927302a313d003f71))
* abstract tool generation into a helper method and set generated files as executable ([f8497d5](https://github.com/redfieldchristabel/laravel-dockerize/commit/f8497d5049a415e2a477535315cbcab7b0499b6a))

## [1.2.0](https://github.com/redfieldchristabel/laravel-dockerize/compare/v1.1.3...v1.2.0) (2026-03-30)


### Features

* add support for disabling options in confirmation steps ([352204b](https://github.com/redfieldchristabel/laravel-dockerize/commit/352204b401aa7bc927473fd9d1fa38e1cdc06160))

## [1.1.3](https://github.com/redfieldchristabel/laravel-dockerize/compare/v1.1.2...v1.1.3) (2026-03-20)


### Bug Fixes

* enhance scaffolding log messages and use PHP version value ([2c3bbe2](https://github.com/redfieldchristabel/laravel-dockerize/commit/2c3bbe21819c18e8f41196fc98b0ae1202dd9b48))

## [1.1.2](https://github.com/redfieldchristabel/laravel-dockerize/compare/v1.1.1...v1.1.2) (2026-03-20)


### Bug Fixes

* add rocket emoji to wizard completion log message ([e7019c7](https://github.com/redfieldchristabel/laravel-dockerize/commit/e7019c70f8966eb2e564e5679e05a072a15b05f0))

## [1.1.1](https://github.com/redfieldchristabel/laravel-dockerize/compare/v1.1.0...v1.1.1) (2026-03-20)


### Bug Fixes

* **ci:** test ([3263047](https://github.com/redfieldchristabel/laravel-dockerize/commit/326304724895afe62276b3255feb2c2f75fae721))

## [1.1.0](https://github.com/redfieldchristabel/laravel-dockerize/compare/v1.0.0...v1.1.0) (2026-03-20)


### Features

* add .env and Vite configuration services to the scaffold command ([cae3fef](https://github.com/redfieldchristabel/laravel-dockerize/commit/cae3fefa8f7d347d6bb9c38eedba93849ec2097f))
* add `generate` command placeholder ([3bb7609](https://github.com/redfieldchristabel/laravel-dockerize/commit/3bb7609dae83e88d6db1960bdb9b944f552b2765))
* add `removeBuild` method to `ManageDockerCompose` ([b08613b](https://github.com/redfieldchristabel/laravel-dockerize/commit/b08613bdedfcdb4ff3eb436489c4f899677923c3))
* dynamic database and service configuration for production docker-compose ([9cec0c2](https://github.com/redfieldchristabel/laravel-dockerize/commit/9cec0c2c87bfb23321942a23976643bfe843908c))
* Make cli scaffold command can only be run on valid Laravel project. ([3356e99](https://github.com/redfieldchristabel/laravel-dockerize/commit/3356e99b8fb4a349c28450019cf74fa2a7e7f53f))
* refactor database service injection and update docker-compose templates ([364a123](https://github.com/redfieldchristabel/laravel-dockerize/commit/364a123f4a588cf81ac3c00e43cdb961012e234a))
* update docker-compose image handling for Octane and App services ([32fd3be](https://github.com/redfieldchristabel/laravel-dockerize/commit/32fd3be5fe46644bf3f1f80adc04e50f88f949bd))


### Bug Fixes

* prevent ArgumentError in `removeBuild` when build block is missing ([5bed1ac](https://github.com/redfieldchristabel/laravel-dockerize/commit/5bed1ac3593be604931dedd15ef2f579cd5db49a))
* remove build steps for queue and scheduler in generator ([7c4a524](https://github.com/redfieldchristabel/laravel-dockerize/commit/7c4a524b4dabe7df38dbbe540e321e1e48d0310e))
* remove database dependency from scheduler in generator service ([3f9af1b](https://github.com/redfieldchristabel/laravel-dockerize/commit/3f9af1b7b56965fe3b181e4925f2c77292964330))
* use phpVersion value in generator and format imports ([7919cea](https://github.com/redfieldchristabel/laravel-dockerize/commit/7919cea0bf9507d3242f81ff4903eecc16e84b0e))
* use raw strings for octane app image paths in generator ([b46415c](https://github.com/redfieldchristabel/laravel-dockerize/commit/b46415c5429022798cc0b090d115cd562add4a66))
* use service name for lookup and add DockerComposeEditor tests ([819733c](https://github.com/redfieldchristabel/laravel-dockerize/commit/819733ccd25be334d9a957c4b80163430bccd5ef))
* use single-quoted scalars for Docker images in compose file ([6c32477](https://github.com/redfieldchristabel/laravel-dockerize/commit/6c32477bf205c05de7da764407337c4da751776e))
* use value property for PHP version logging in generator ([bdf8989](https://github.com/redfieldchristabel/laravel-dockerize/commit/bdf8989aa6d8bd7cda7e711bdb7649861bbae4d8))

## [1.1.0](https://github.com/redfieldchristabel/laravel-dockerize/compare/v1.0.0...v1.1.0) (2026-03-19)


### Features

* add .env and Vite configuration services to the scaffold command ([cae3fef](https://github.com/redfieldchristabel/laravel-dockerize/commit/cae3fefa8f7d347d6bb9c38eedba93849ec2097f))
* add `removeBuild` method to `ManageDockerCompose` ([b08613b](https://github.com/redfieldchristabel/laravel-dockerize/commit/b08613bdedfcdb4ff3eb436489c4f899677923c3))
* dynamic database and service configuration for production docker-compose ([9cec0c2](https://github.com/redfieldchristabel/laravel-dockerize/commit/9cec0c2c87bfb23321942a23976643bfe843908c))
* refactor database service injection and update docker-compose templates ([364a123](https://github.com/redfieldchristabel/laravel-dockerize/commit/364a123f4a588cf81ac3c00e43cdb961012e234a))
* update docker-compose image handling for Octane and App services ([32fd3be](https://github.com/redfieldchristabel/laravel-dockerize/commit/32fd3be5fe46644bf3f1f80adc04e50f88f949bd))


### Bug Fixes

* prevent ArgumentError in `removeBuild` when build block is missing ([5bed1ac](https://github.com/redfieldchristabel/laravel-dockerize/commit/5bed1ac3593be604931dedd15ef2f579cd5db49a))
* remove build steps for queue and scheduler in generator ([7c4a524](https://github.com/redfieldchristabel/laravel-dockerize/commit/7c4a524b4dabe7df38dbbe540e321e1e48d0310e))
* remove database dependency from scheduler in generator service ([3f9af1b](https://github.com/redfieldchristabel/laravel-dockerize/commit/3f9af1b7b56965fe3b181e4925f2c77292964330))
* use phpVersion value in generator and format imports ([7919cea](https://github.com/redfieldchristabel/laravel-dockerize/commit/7919cea0bf9507d3242f81ff4903eecc16e84b0e))
* use raw strings for octane app image paths in generator ([b46415c](https://github.com/redfieldchristabel/laravel-dockerize/commit/b46415c5429022798cc0b090d115cd562add4a66))
* use service name for lookup and add DockerComposeEditor tests ([819733c](https://github.com/redfieldchristabel/laravel-dockerize/commit/819733ccd25be334d9a957c4b80163430bccd5ef))
* use single-quoted scalars for Docker images in compose file ([6c32477](https://github.com/redfieldchristabel/laravel-dockerize/commit/6c32477bf205c05de7da764407337c4da751776e))
* use value property for PHP version logging in generator ([bdf8989](https://github.com/redfieldchristabel/laravel-dockerize/commit/bdf8989aa6d8bd7cda7e711bdb7649861bbae4d8))

## 1.0.0

- Initial version.
