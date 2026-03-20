# Changelog

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
