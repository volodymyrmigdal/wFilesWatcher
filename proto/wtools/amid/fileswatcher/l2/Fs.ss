( function _Fs_s_()
{

'use strict';

/**
 * @namespace Tools.files.watcher.fs
 * @module Tools/mid/FilesWather
 */

const _global = _global_;
const _ = _global_.wTools;
_.assert( !!_.files.watcher );
const watcher = _.files.watcher;
const Self = watcher.fb = watcher.fb || Object.create( null );

let Extension =
{
}

_.props.supplement( _.files, Extension );

})();
