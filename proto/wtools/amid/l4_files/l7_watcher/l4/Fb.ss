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

function _enable()
{
  let self = this;
  let ready = _.take( null );

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
      self.client.command([ 'watch-project', filePath ], ( err, resp ) =>
      {
        if( err )
        return con.error( _.err( 'Error initiating watch:', err ) );

        // It is considered to be best practice to show any 'warning' or
        // 'error' information to the user, as it may suggest steps
        // for remediation
        if( 'warning' in resp)
        {
          logger.log( 'warning: ', resp.warning );
        }
        // `watch-project` can consolidate the watch for your
        // dir_of_interest with another watch at a higher level in the
        // tree, so it is very important to record the `relative_path`
        // returned in resp
        logger.log( 'watch established on ', resp.watch, ' relative_path', resp.relative_path );

        let descriptor =
        {
          watch : resp.watch,
          clock : resp.clock,
          relativePath : resp.relative_path,
          filePath
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

      if( self.subscriptionMap[ descriptor.watch ] )
      return;

      let subscriptionDescriptor =
      {
        expression: [ 'allof', [ 'match', '*' ] ],
        fields: [ 'name', 'size', 'exists', 'type' ],
        relative_path : descriptor.relativePath
      };

      self.subscriptionMap[ descriptor.watch ] = { subscriptionDescriptor, watchDescriptor : descriptor };

      let con = _.Consequence();
      self.client.command([ 'subscribe', descriptor.watch, 'defaultSub', subscriptionDescriptor ], con.tolerantCallback() );
      cons.push( con );
    });

    return _.Consequence.AndKeep( ... cons );
  })

  ready.then( () =>
  {
    self.client.on( 'subscription', ( resp ) =>
    {
      if( resp.canceled )
      return;

      if( resp.is_fresh_instance )
      return;

      let files = resp.files.map( ( file ) =>
      {
        let record = Object.create( null );
        record.filePath = file.name;
        record.watchPath = resp.root;
        record.size = file.size;
        record.native = file;
        return record;
      })

      let e =
      {
        kind : 'change',
        watcher : self,
        reason : null,
        files
      }

      self.eventGive( e );
    });

    return null;
  })

  ready.then( () =>
  {
    self.enabled = true;
    return self;
  })

  return ready;
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
      logger.log( 'watch established on ', resp.watch, ' relative_path', resp.relative_path );

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

  return ready;
}

//

function watch( filePath, o )
{
  _.assert( arguments.length === 1 || arguments.length === 2 );

  o = o || Object.create( null );

  _.routine.options_( watch, o );

  let watcher = new Self({ filePath, manager : o.manager });

  if( o.enabled )
  return watcher.resume();

  return watcher;
}

watch.defaults =
{
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
  watch
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
