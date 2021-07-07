( function _Fb_s_()
{

'use strict';

/**
 * Facebook's watch
 * @namespace Tools.files.watcher.fb
 * @module Tools/mid/FilesWather
 */

const _global = _global_;
const _ = _global_.wTools;
_.assert( !!_.files.watcher );
_.assert( !!_.files.watcher.abstract );
_.assert( !_.files.watcher.fb );

const Watchman = require( 'fb-watchman' );

// --
// implementation
// --

const Parent = _.files.watcher.abstract;
const Self = WatcherFb;
function WatcherFb( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'WatcherFb';

//

function _featuresForm()
{
  let self = this;
  let features = self.Features;

  features.recursion = true;

  return _.Consequence.AndKeep
  (
    self._watchedDirRenameDetection(),
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
  let timeOut = false;

  _.fileProvider.dirMake( srcPath );

  let client = new Watchman.Client();

  client.capabilityCheck({ optional : [], required : [ 'relative_root' ] }, ( err, resp ) =>
  {
    if( err )
    return con1.error( err );

    if( timeOut )
    return;

    srcPath = _.fileProvider.pathResolveLinkFull( srcPath ).absolutePath;
    client.command([ 'watch-project', _.path.nativize( srcPath ) ], ( err, resp ) =>
    {
      if( err )
      return con1.error( err );

      if( timeOut )
      return;

      let subscriptionDescriptor =
      {
        expression: [ 'allof', [ 'match', '*' ] ],
        fields: [ 'name', 'size', 'exists', 'type', 'new' ],
        relative_path : resp.relative_path
      };

      client.command([ 'subscribe', resp.watch, 'testSub', subscriptionDescriptor ], ( err, resp ) =>
      {
        if( err )
        return con1.error( err );

        if( timeOut )
        return;

        client.on( 'subscription', ( resp ) =>
        {
          if( resp.canceled )
          return;

          if( resp.is_fresh_instance )
          return;

          for( let i = 0; i < resp.files.length; i++ )
          {
            let file = resp.files[ i ];
            if( file.name === srcName )
            features.watchedDirRenameDetection = true;
          }

          con1.take( null );
        })
        _.fileProvider.fileRename( dstPath, srcPath );
      });
    })
  })

  let con2 = _.time.out( 500, () =>
  {
    timeOut = true;
    return null;
  });
  let con = _.Consequence.OrTake( con1, con2 )

  con.finally( async ( err, got ) =>
  {
    if( err )
    _.errAttend( err );
    _.fileProvider.filesDelete( dstPath );
    let ready = _.take( null );
    ready.thenGive( () => client.command( [ 'shutdown-server' ], ready.tolerantCallback() ) );
    await ready;
    if( err )
    throw err;
    return got;
  })

  return con;
}

//

function _enable()
{
  let self = this;
  let ready = _.take( null );
  let features = self.Features;

  if( self.enabled )
  {
    _.assert( self.client instanceof Watchman.Client );
    return ready;
  }

  ready.then( () =>
  {
    self.client = new Watchman.Client();

    let con = _.Consequence();
    self.client.capabilityCheck({ optional : [], required : [ 'relative_root' ] }, con.tolerantCallback() )
    return con;
  })

  ready.then( () =>
  {
    let cons = [];

    _.each( self.filePath, ( val, filePath ) =>
    {
      let con = _.Consequence();
      cons.push( con );

      if( !_.fileProvider.fileExists( filePath ) )
      return con.error( _.err( `Error initiating watch: provided path doesn't exist.\nFile path: ${filePath}` ) )
      debugger
      let resolveOptions = { filePath };
      let filePathToWatchResolved = _.fileProvider.pathResolveLinkFull( resolveOptions );
      let filePathToWatch = filePathToWatchResolved.absolutePath;
      if( !features.watchedDirRenameDetection || !_.fileProvider.isDir( filePathToWatch ) )
      filePathToWatch = _.path.dir( filePathToWatch );

      self.client.command([ 'watch-project', _.path.nativize( filePathToWatch ) ], ( err, resp ) =>
      {
        if( err )
        return con.error( _.err( 'Error initiating watch:', err ) );

        // It is considered to be best practice to show any 'warning' or
        // 'error' information to the user, as it may suggest steps
        // for remediation
        if( 'warning' in resp )
        {
          logger.log( 'warning: ', resp.warning );
        }
        // `watch-project` can consolidate the watch for your
        // dir_of_interest with another watch at a higher level in the
        // tree, so it is very important to record the `relative_path`
        // returned in resp
        // logger.log( 'watch established on ', resp.watch, ' relative_path', resp.relative_path );

        let descriptor =
        {
          watch : resp.watch,
          clock : resp.clock,
          relativePath : resp.relative_path,
          filePath
        }

        if( !features.watchedDirRenameDetection )
        {
          descriptor.relativeWatchPath = _.path.fullName( filePathToWatchResolved.absolutePath );
          descriptor.ino = resolveOptions.stat.ino;
        }

        self.watcherArray.push( descriptor );

        con.take( null )
      })
    })

    return _.Consequence.AndKeep( ... cons );
  })

  ready.then( () =>
  {
    let cons = [];

    self.watcherArray.forEach( ( descriptor ) =>
    {
      /* Avoid subscription duplication for the same root path */

      if( self.subscriptionMap[ descriptor.filePath ] )
      return;

      let expression = [ 'anyof', [ 'match', '*' ] ];

      let subscriptionDescriptor =
      {
        /* Doc for fields: https://facebook.github.io/watchman/docs/cmd/query.html#available-fields */
        expression,
        fields : [ 'name', 'size', 'exists', 'type', 'new', 'ino', 'mtime_ms' ],
        relative_path : descriptor.relativePath
      };

      if( self.filter )
      {
        _.assert( 0, 'not tested' );
        subscriptionDescriptor.expression = [ 'anyof' ];
        self.filter.forEach( ( e ) =>
        {
          subscriptionDescriptor.expression.push( [ 'match', e ] )
        })
      }

      self.subscriptionMap[ descriptor.filePath ] = { subscriptionDescriptor, watchDescriptor : descriptor };

      let con = _.Consequence();
      self.client.command([ 'subscribe', descriptor.watch, descriptor.filePath, subscriptionDescriptor ], con.tolerantCallback() );
      cons.push( con );
    });

    return _.Consequence.AndKeep( ... cons );
  })

  ready.then( () => _subscribe.call( self ) )

  ready.then( () =>
  {
    self.enabled = true;
    return self;
  })

  ready.catch( async( err ) =>
  {
    _.errAttend( err );

    let con = _.take( null )

    con.thenGive( () => self.client.command( [ 'watch-del-all' ], con.tolerantCallback() ) );
    con.thenGive( () => self.client.command( [ 'shutdown-server' ], con.tolerantCallback() ) );

    await con;

    throw _.errLogOnce( err );
  })

  return ready;
}

//

function _subscribe()
{
  let self = this;
  let client = self.client;
  let features = self.Features;

  client.on( 'subscription', subscriptionHandler );

  return null;

  /* */

  function subscriptionHandler( resp )
  {
    if( resp.canceled )
    return;

    if( resp.is_fresh_instance )
    return;

    let sub = self.subscriptionMap[ resp.subscription ];
    let watchDescriptor = sub.watchDescriptor;
    let oroot = resp.root;
    let files = [];
    let terminals = [];

    resp.files.forEach( ( file ) =>
    {
      if( file.type === 'd' )
      files.push( file )
      else
      terminals.push( file )
    });
    files.push( ... terminals );

    let changeMap =
    {
      'modify' : [],
      'delete' : [],
      'add' : []
    }

    files.forEach( ( file ) =>
    {
      if( !features.watchedDirRenameDetection )
      {
        if( file.exists && !file.ino )
        {
          let stat = _.fileProvider.statRead( _.path.join( oroot, file.name ) );
          if( stat )
          file.ino = stat.ino;
        }

        if( !_.strBegins( file.name, watchDescriptor.relativeWatchPath ) )
        {
          if( !file.ino )
          return;

          if( BigInt( file.ino ) !== watchDescriptor.ino )
          return;

          if( file.new )
          {
            watchDescriptor.ino = BigInt( file.ino );
            watchDescriptor.relativeWatchPath = file.name;
            resp.root = _.path.join( oroot, watchDescriptor.relativeWatchPath );
            file.name = _.path.relative( watchDescriptor.relativeWatchPath, file.name );
          }
        }

        if( BigInt( file.ino ) === watchDescriptor.ino )
        {
          let isDir = file.type === 'd';
          if( isDir && !file.new && file.exists )
          return;
        }
        else
        {
          resp.root = _.path.join( oroot, watchDescriptor.relativeWatchPath );
          file.name = _.path.relative( watchDescriptor.relativeWatchPath, file.name );
        }
      }

      let record = Object.create( null );
      record.filePath = file.name;
      record.watchPath = resp.root;
      record.size = file.size;
      record.native = file;

      record.changeType = 'modify';

      if( !file.exists )
      record.changeType = 'delete';
      else if( file.new )
      record.changeType = 'add'

      let e =
      {
        kind : 'file.change',
        watcher : self,
        files : [ record ]
      }

      changeMap[ record.changeType ].push( e );

    })

    changeMap.delete.forEach( ( e ) => reportChange( e ) )
    changeMap.add.forEach( ( e ) => reportChange( e ) )
    changeMap.modify.forEach( ( e ) => reportChange( e ) )

  }

  function reportChange( e )
  {
    self.manager._onChange( e );
    self.onChange( e );
  }

}

//

function _unsubscribe()
{
  let self = this;
  let cons = [];

  self.watcherArray.forEach( ( descriptor ) =>
  {
    let con = _.Consequence();
    self.client.command([ 'unsubscribe', descriptor.watch, 'defaultSub' ], con.tolerantCallback() );
    cons.push( con );
  });

  return _.Consequence.AndKeep( ... cons );
}

//

function _unwatch()
{
  let self = this;
  let cons = [];

  self.watcherArray.forEach( ( descriptor ) =>
  {
    let con = _.Consequence();
    self.client.command([ 'watch-del', descriptor.watch ], con.tolerantCallback() );
    cons.push( con );
  });

  return _.Consequence.AndKeep( ... cons );
}

//

function _resubscribe()
{
  let self = this;
  let cons = [];

  for( let k in self.subscriptionMap )
  {
    let sub = self.subscriptionMap[ k ];
    let watchDescriptor = sub.watchDescriptor;
    let subscriptionDescriptor = sub.subscriptionDescriptor;
    let con = _.Consequence();
    self.client.command([ 'subscribe', watchDescriptor.watch, 'defaultSub', subscriptionDescriptor ], con.tolerantCallback() );
    cons.push( con );
  }

  return _.Consequence.AndKeep( ... cons );
}

//

function _rewatch()
{
  let self = this;
  let cons = [];

  self.watcherArray.forEach( ( descriptor ) =>
  {
    let con = _.Consequence();
    self.client.command([ 'watch-project', descriptor.filePath ], ( err, resp ) =>
    {
      if( err )
      return con.error( _.err( 'Error initiating watch:', err ) );

      if( 'warning' in resp)
      {
        logger.log( 'warning: ', resp.warning );
      }
      // logger.log( 'watch established on ', resp.watch, ' relative_path', resp.relative_path );

      descriptor.watch = resp.watch;
      descriptor.clock = resp.clock;
      descriptor.relativePath = resp.relative_path;

      con.take( null )
    })
    cons.push( con );
  });

  return _.Consequence.AndKeep( ... cons );
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
  ready.then( () => _resubscribe.call( self ) )

  return self;
}

//

function _pause()
{
  let self = this;

  if( self.paused )
  return null;

  let ready = _.take( null )

  ready.then( () => _unsubscribe.call( self ) )
  ready.then( () => _unwatch.call( self ) )

  return ready;
}

//

function _close()
{
  let self = this;

  if( !self.enabled )
  return null;

  let ready = _.take( null );

  ready.thenGive( () => self.client.command( [ 'watch-del-all' ], ready.tolerantCallback() ) );
  ready.thenGive( () => self.client.command( [ 'shutdown-server' ], ready.tolerantCallback() ) );
  ready.delay( 1000 );//workaround for shutdown problem on Windows https://github.com/facebook/watchman/issues/764

  return ready;
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

  _.routine.options_( watch, o );

  _.assert( o.filePath !== undefined );
  _.assert( _.routineIs( o.onChange ) );

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
  manager : null
}

//

let Composes =
{
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
  watcherArray : _.define.own([]),
  subscriptionMap : _.define.own({}),

  client : null,
}

//

let Extension =
{
  _featuresForm,
  _watchedDirRenameDetection,

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

_.assert( _.files.watcher.default === null );
_.assert( !_.files.watcher.fb );

_.files.watcher.fb = Self;
_.files.watcher.default = _.files.watcher.fb;

})();
