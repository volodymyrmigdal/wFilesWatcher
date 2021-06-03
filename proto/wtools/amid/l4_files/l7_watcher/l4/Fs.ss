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
_.assert( !!_.files.watcher.defaultManager );
_.assert( !_.files.watcher.fs );

const Fs = require( 'fs' );

// --
// implementation
// --

const Parent = _.files.watcher.abstract;
const Self = WatcherFs;
function WatcherFs( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'WatcherFs';

//

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
    if( self.watcherArray === null )
    self.watcherArray = [];

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

  ready.catch( ( err ) =>
  {
    _.errAttend( err );
    return _unwatch.call( self )
    .then( () =>
    {
      throw err;
    });
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
  watcher.on( 'change', function ( type, filename )
  {
    let record = Object.create( null );
    record.filePath = filename;
    record.watchPath = watcher.filePath;
    record.type = type;
    record.size = null;
    record.native = arguments;

    let e =
    {
      kind : 'change',
      watcher : self,
      reason : null,
      files : [ record ]
    }

    self.eventGive( e );
  });

  watcher.on( 'error', function( err )
  {
    let e =
    {
      kind : 'error',
      watcher : self,
      err
    }
    self.eventGive( e );
  })
}

//

function _unwatch()
{
  let self = this;
  let cons = [];

  self.watcherArray.forEach( ( descriptor ) =>
  {
    let con = _.Consequence();
    descriptor.watch.close()
    descriptor.watch.on( 'close', () =>
    {
      descriptor.watch = null;
      con.take( null )
    })
    cons.push( con );
  });

  return _.Consequence.AndKeep( ... cons );
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

//

function watch( filePath, o )
{
  _.assert( arguments.length === 1 || arguments.length === 2 );

  o = o || Object.create( null );

  _.routine.options_( watch, o );

  let watcher = new Self({ filePath, recursive : o.recursive, manager : o.manager });

  if( o.enabled )
  return watcher.resume();

  return watcher;
}

watch.defaults =
{
  enabled : 1,
  recursive : 0,
  manager : null
}

//

let Composes =
{
  recursive : 0
}

//

let Statics =
{
  watch
}

//

let Restricts =
{
  watcherArray : null
}

//

let Extension =
{
  _resume,
  _pause,
  _close,

  Composes,
  Statics,
  Restricts
}

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Extension,
});

//

_.assert( _.files.watcher.default === _.files.watcher.fb );

_.files.watcher.fs = Self;

})();
