( function _Namespace_s_()
{

'use strict';

/**
 * @namespace Tools.files.watcher
 * @module Tools/mid/FilesWather
 */

const _global = _global_;
const _ = _global_.wTools;
const files = _.files = _.files || Object.create( null );
const Self = files.watcher = files.watcher || Object.create( null );

//

function close()
{
  let self = this;
  let cons = self.watcherArray.map( ( watcher ) => watcher.close() );
  return _.Consequence.AndKeep( ... cons );
}

//

let Extension =
{
  default : null,
  watcherArray : [],

  close
}

_.props.supplement( Self, Extension );

})();
