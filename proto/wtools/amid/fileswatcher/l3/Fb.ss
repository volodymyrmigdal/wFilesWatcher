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
const watcher = _.files.watcher;
const Self = watcher.fb = watcher.fb || Object.create( null );

const Watchman = require( 'fb-watchman' );

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
        }

        self.watchers.push( descriptor );

        con.take( null )
      })
    })

    return _.Consequence.AndKeep( ... cons );
  })

  ready.then( () =>
  {
    let subscriptionsMap = Object.create( null );
    let cons = [];

    self.watchers.forEach( ( descriptor ) =>
    {
      /* Avoid subscription duplication for the same root path */

      if( subscriptionsMap[ descriptor.watch ] )
      return;

      let subscriptionDescriptor =
      {
        expression: [ 'allof', [ 'match', '*' ] ],
        fields: [ 'name', 'size', 'exists', 'type' ],
        relative_path : descriptor.relativePath
      };

      subscriptionsMap[ descriptor.watch ] = subscriptionDescriptor;

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

      _.event.eventGive( self.ehandler, { event : 'change', args : [ resp ] } );
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

function _resume()
{
  let self = this;

  if( !self.enabled && !self.client )
  return _enable.call( self );

  if( !self.paused )
  return self;

  throw _.err( 'implement' );

  return self;
}

//

function _pause()
{
  let self = this;

  if( self.paused )
  return null;

  throw _.err( 'implement' )

  return self;
}

//

function _close()
{
  let self = this;

  if( !self.enabled )
  return null;

  let ready = _.Consequence()

  ready.thenGive( () => self.client.command( [ 'watch-del-all' ], ready.tolerantCallback() ) );
  ready.thenGive( () => self.client.command( [ 'shutdown-server' ], ready.tolerantCallback() ) );

  return ready;
}

//

let InterfaceMethods =
{
  _resume,
  _pause,
  _close,
}

//

let InterfaceFields =
{
}

//

let Interface =
{
  ... InterfaceFields,
  ... InterfaceMethods
}

//

function watch( filePath, o )
{
  _.assert( arguments.length === 1 || arguments.length === 2 );

  o = o || Object.create( null );

  _.routine.options_( watch, o );

  let o2 = Object.create( watcher.abstract );

  _.props.extend( o2, Interface )

  o2.filePath = _.path.mapsPair( null, filePath );

  if( o.enabled )
  o2.resume();

  return o2;
}

watch.defaults =
{
  enabled : 1
}

//

let Extension =
{
  watch,
}

_.props.supplement( Self, Extension );
_.assert( watcher.default === null );

watcher.default = Self;

})();
