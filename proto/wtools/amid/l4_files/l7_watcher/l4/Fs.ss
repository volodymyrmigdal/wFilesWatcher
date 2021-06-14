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
const IsMacOrWin = process.platform === 'win32' || process.platform === 'darwin';

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

function _featuresForm()
{
  let self = this;
  let features = self.Features;

  /* recursion */

  features.recursion = IsMacOrWin;

  /* */

  return _.Consequence.AndKeep
  (
    self._watchedDirRenameDetection(),
    self._watchedSymlinkChangeDetection()
  );
}

//

function _watchedDirRenameDetection()
{
  let self = this;
  let features = self.Features;

  features.watchedDirRenameDetection = false;

  let con1 = _.Consequence();

  let tempDir = _.path.dirTemp();
  let srcName = _.idWithDateAndTime();
  let srcPath = _.path.join( tempDir, srcName );
  let dstPath = _.path.join( tempDir, _.idWithDateAndTime() );

  _.fileProvider.dirMake( srcPath );

  let watch = Fs.watch( _.path.nativize( srcPath ), {}, ( type, filename ) =>
  {
    if( type !== 'rename' )
    return;
    features.watchedDirRenameDetection = filename === srcName;
    con1.take( null );
  })

  _.fileProvider.fileRename( dstPath, srcPath );

  let con2 = _.time.out( 500 );
  let con = _.Consequence.OrTake( con1, con2 )

  con.thenGive( () =>
  {
    watch.close();
    _.fileProvider.fileDelete( dstPath );
    watch.on( 'close', () => con.take( self ) )
  })

  return con;
}

//

function _watchedSymlinkChangeDetection()
{
  let self = this;
  let features = self.Features;

  features.watchedSymlinkChangeDetection = false;

  let con1 = _.Consequence();

  let tempDir = _.path.dirTemp();
  let srcName = _.idWithDateAndTime();
  let srcPath = _.path.join( tempDir, srcName );
  let linkPath = _.path.join( tempDir, _.idWithDateAndTime() );

  _.fileProvider.fileWrite( srcPath, srcPath );
  _.fileProvider.softLink( linkPath, srcPath );

  let watch = Fs.watch( _.path.nativize( linkPath ), {}, ( type, filename ) =>
  {
    features.watchedSymlinkChangeDetection = true;
    con1.take( null );
  })

  _.fileProvider.fileWrite( linkPath, srcPath );

  let con2 = _.time.out( 500 );
  let con = _.Consequence.OrTake( con1, con2 )

  con.thenGive( () =>
  {
    watch.close();
    _.fileProvider.fileDelete( linkPath );
    _.fileProvider.fileDelete( srcPath );
    watch.on( 'close', () => con.take( self ) )
  })

  return con;
}

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

    if( self.recursive === null )
    self.recursive = self.Features.recursion;

    _.each( self.filePath, ( val, filePath ) =>
    {
      if( !self.Features.watchedSymlinkChangeDetection && _.fileProvider.isSoftLink( filePath ) )
      filePath = _.fileProvider.pathResolveSoftLink( filePath );

      let watcherDescriptor = Object.create( null );
      watcherDescriptor.clock = process.hrtime.bigint();
      watcherDescriptor.clockMs = watcherDescriptor.clock / BigInt( 1000000 );

      if( !self.Features.watchedDirRenameDetection && _.fileProvider.isDir( filePath ) && !_.path.isRoot( filePath ))
      {
        watcherDescriptor.filePath = _.path.dir( filePath );
        watcherDescriptor.relativeWatchPath = _.path.fullName( filePath );
        watcherDescriptor.absolutePath = filePath;
        watcherDescriptor.recursive = true;
        watcherDescriptor.stat = _.fileProvider.statRead( filePath );
        watcherDescriptor.watch = _watcherMakeFor.call( self, watcherDescriptor.filePath, watcherDescriptor.recursive );
        self.watcherArray.push( watcherDescriptor );
        _watcherRegisterCallbacks.call( self, watcherDescriptor )
      }
      else
      {
        watcherDescriptor.filePath = filePath;
        watcherDescriptor.recursive = self.recursive;
        watcherDescriptor.watch = _watcherMakeFor.call( self, filePath, watcherDescriptor.recursive );

        self.watcherArray.push( watcherDescriptor );
        _watcherRegisterCallbacks.call( self, watcherDescriptor )
      }

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

function _watcherMakeFor( filePath, recursive )
{
  let self = this;
  if( recursive === undefined )
  recursive = self.recursive;
  let op = Object.create( null );
  op.recursive = !!recursive;
  let watch = Fs.watch( _.path.nativize( filePath ), op );
  watch.filePath = filePath;
  return watch;
}

//

function _watcherRegisterCallbacks( watcherDescriptor )
{
  let self = this;
  let watcher = watcherDescriptor.watch;

  watcher.on( 'change', function ( type, filename )
  {
    if( watcherDescriptor.relativeWatchPath )
    {
      let filePath = _.path.join( watcher.filePath, filename );
      let stat = _.fileProvider.statRead({ filePath, throwing : 0 });

      if( !_.strBegins( filename, watcherDescriptor.relativeWatchPath ) )
      {
        if( type !== 'rename' )
        return false;
        if( !stat )
        return false;
        if( stat.ino !== watcherDescriptor.stat.ino )
        return false;
        watcherDescriptor.relativeWatchPath = _.path.fullName( filePath );
      }
      else if( stat && stat.ino !== watcherDescriptor.stat.ino )
      {
        watcherDescriptor.stat = stat;
      }
    }


    if( self.filter )
    if( !self.logic.exec({ onEach : ( e ) => e.test( filename ) }) )
    return;

    let record = Object.create( null );

    record.type = type;
    record.size = null;
    record.native = arguments;

    record.filePath = filename;
    record.watchPath = watcher.filePath;

    record.changeType = 'modify'

    let stat = _.fileProvider.statRead( _.path.join( record.watchPath, record.filePath ) );
    if( !stat )
    record.changeType = 'delete';
    else if( stat.birthtimeNs && stat.birthtimeNs >= watcherDescriptor.clock )
    record.changeType = 'add'
    else if( stat.birthtimeMs >= watcherDescriptor.clockMs )
    record.changeType = 'add'

    if( watcherDescriptor.relativeWatchPath )
    {
      record.watchPath = watcherDescriptor.absolutePath;
      if( watcherDescriptor.relativeWatchPath !== filename )
      record.filePath = _.path.relative( watcherDescriptor.relativeWatchPath, filename );
    }

    let e =
    {
      kind : 'file.change',
      watcher : self,
      reason : null,
      files : [ record ]
    }

    // self.eventGive( e );
    self.manager._onChange( e );
    self.onChange( e );
  });

  watcher.on( 'error', function( err )
  {
    let e =
    {
      kind : 'error',
      watcher : self,
      err
    }
    // self.eventGive( e );
    self.manager._onError( e );

    if( self.onError )
    self.onError( e );
    else
    throw _.errLogOnce( err );
  })
}

//


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
    descriptor.watch = _watcherMakeFor.call( self, descriptor.filePath, descriptor.recursive );
    _watcherRegisterCallbacks.call( self, descriptor );
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

function watch( filePath, onChange )
{
  _.assert( arguments.length === 1 || arguments.length === 2 );

  let o;

  if( arguments.length === 1 )
  {
    o = arguments[ 0 ];
  }
  else if( _.routineIs( onChange ) )
  {
    o = { filePath, onChange }
  }
  else
  {
    o = onChange;
    _.assert( _.object.is( o ) )
    _.assert( o.filePath === undefined )
    o.filePath = filePath;
  }

  _.assert( o.filePath !== undefined );
  _.assert( _.routineIs( o.onChange ) );

  _.routine.options_( watch, o );

  let watcher = new Self( _.mapBut_( null, o, { enabled : null } ) );

  if( o.enabled )
  return watcher.resume();

  return watcher;
}

watch.defaults =
{
  filePath : null,
  onChange : null,
  onError : null,
  filter : null,
  enabled : 1,
  recursive : null,
  manager : null,

}

//

let Composes =
{
  recursive : null
}

//

let Statics =
{
  watch,

  Features : Object.create( Parent.FeaturesTemplate )
}

//

let Restricts =
{
  watcherArray : null
}

//

let Extension =
{
  _watchedDirRenameDetection,
  _watchedSymlinkChangeDetection,
  _featuresForm,

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
