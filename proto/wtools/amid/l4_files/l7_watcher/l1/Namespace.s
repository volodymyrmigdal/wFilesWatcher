( function _Namespace_s_()
{

'use strict';

/**
 * @namespace Tools.files.watcher
 * @module Tools/mid/FilesWather
 */

const _global = _global_;
const _ = _global_.wTools;
_.files = _.files || Object.create( null );
_.files.watcher = _.files.watcher || Object.create( null );

//

function close()
{
  let self = this;
  let cons = self.watcherArray.map( ( watcher ) => watcher.close() );
  return _.Consequence.AndKeep( ... cons );
}

// --
// extension
// --

let Extension =
{

  close,

  default : null,
  watcherArray : [],

}

Object.assign( _.files.watcher, Extension );

})();
