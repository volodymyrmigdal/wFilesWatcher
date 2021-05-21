( function _Fs_s_()
{

'use strict';

/**
 * Facebook's watch
 * @namespace Tools.files.watcher.fs
 * @module Tools/mid/FilesWather
 */

const _global = _global_;
const _ = _global_.wTools;
_.assert( !!_.files.watcher );
_.assert( !!_.files.watcher.abstract );
_.watcher.fs = _.watcher.fs || Object.create( null );

const Fs = require( 'fs' );

// --
// implementation
// --

function _enable()
{
  let self = this;
  let ready = _.take( null );

  if( self.enabled )
  {
    return ready;
  }

  ready.then( () =>
  {
    _.each( self.filePath, ( val, filePath ) =>
    {
      let watcherDescriptor = Object.create( null );
      watcherDescriptor.filePath = filePath;
      watcherDescriptor.watch = _watcherMakeFor.call( self, filePath );

      self.watcherArray.push( watcherDescriptor );
      _watcherRegisterCallbacks.call( self, watcherDescriptor.watch )
    })

    self.enabled = true;
    return self;
  })

  return ready;
}

//

function _watcherMakeFor( filePath )
{
  let self = this;
  let op = { recursive : self.recursive };
  let watch = Fs.watch( _.path.nativize( filePath ), op );
  watch.filePath = filePath;
  return watch;
}

//

function _watcherRegisterCallbacks( watcher )
{
  let self = this;
  watcher.on( 'change', ( type, filename ) =>
  {
    let record = Object.create( null );
    record.filePath = filename;
    record.watchPath = watcher.filePath;
    record.size = null;
    record.native = arguments;

    let e =
    {
      kind : 'change',
      watcher : self,
      reason : null,
      files : [ record ]
    }

    _.event.eventGive( self.ehandler, { event : 'change', args : [ e ] } );
  });
}

//

function _unwatch()
{
  let self = this;

  self.watcherArray.forEach( ( descriptor ) =>
  {
    descriptor.watch.close()
    descriptor.watch = null;
  });

  return null;
}

//

function _rewatch()
{
  let self = this;

  self.watcherArray.forEach( ( descriptor ) =>
  {
    descriptor.watch = _watcherMakeFor.call( self, descriptor.filePath );
    _watcherRegisterCallbacks.call( self, descriptor.watch )
  });

  return null;
}

//

function _resume()
{
  let self = this;

  if( !self.enabled && !self.client )
  return _enable.call( self );

  if( !self.paused )
  return self;

  let ready = _.take( null )

  ready.then( () => _rewatch.call( self ) )

  return self;
}

//

function _pause()
{
  let self = this;

  if( self.paused )
  return null;

  _unwatch.call( self );

  return null;
}

//

function _close()
{
  let self = this;

  if( !self.enabled )
  return null;

  _unwatch.call( self )

  _.longEmpty( self.watcherArray );

  return null;
}

// //
//
// let InterfaceMethods =
// {
//   _resume,
//   _pause,
//   _close,
// }
//
// //
//
// let InterfaceFields =
// {
//   watcherArray : []
// }
//
// //
//
// let Interface =
// {
//   ... InterfaceFields,
//   ... InterfaceMethods
// }

//

function watch( filePath, o )
{
  _.assert( arguments.length === 1 || arguments.length === 2 );

  o = o || Object.create( null );

  _.routine.options_( watch, o );

  let o2 = Object.create( watcher.abstract );

  _.arrayAppendElementOnceStrictly( watcher.watcherArray, o2 );

  _.props.extend( o2, Interface )

  o2.filePath = _.path.mapsPair( null, filePath );
  o2.recursive = o.recursive;

  if( o.enabled )
  return o2.resume();

  return o2;
}

watch.defaults =
{
  enabled : 1,
  recursive : 0,
  watcherArray : [],
  _resume,
  _pause,
  _close,
}

// --
// extension
// --

let Extension =
{
  watch,
}

Object.assign( _.watcher.fs, Extension );
_.assert( watcher.default === watcher.fb );

})();
