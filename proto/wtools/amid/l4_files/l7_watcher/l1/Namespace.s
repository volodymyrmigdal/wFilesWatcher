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
  _.assert( self.defaultManager === null || _.longHas( self.managerArray, self.defaultManager ) )
  let cons = self.managerArray.map( ( manager ) => manager.close() );
  return _.Consequence.AndKeep( ... cons );
}

// --
// extension
// --

let Extension =
{

  close,

  default : null,
  defaultManager : null,
  managerArray : [],

}

Object.assign( _.files.watcher, Extension );

})();
