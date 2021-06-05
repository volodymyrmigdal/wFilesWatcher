# module::FilesWatcher  [![status](https://github.com/Wandalen/wFilesWatcher/workflows/publish/badge.svg)](https://github.com/Wandalen/wFilesWatcher/actions?query=workflow%3Apublish) [![stability-experimental](https://img.shields.io/badge/stability-experimental-orange.svg)](https://github.com/emersion/stability-badges#experimental)

Aggregates file watching strategies and provides a single interface to them. The strategy can be a wrapper around a built-in feature or a separate library. Use the module to easily create watcher instances, pause/resume watchers, switch between watcher strategies and control created watchers using the watcher manager class.

### Try out from the repository

```
git clone https://github.com/Wandalen/wFilesWatcher
cd wFilesWatcher
will .npm.install
node sample/trivial/Sample.s
```

Make sure you have utility `willbe` installed. To install willbe: `npm i -g willbe@stable`. Willbe is required to build of the module.

### To add to your project
```
npm add 'wfileswatcher@stable'
```

`Willbe` is not required to use the module in your project as submodule.
