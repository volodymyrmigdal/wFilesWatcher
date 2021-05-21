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
const watcher = _.files.watcher;
const Self = watcher.fb = watcher.fb || Object.create( null );
let Watchman = null;

//

function enable()
{
  let self = this;
  let client = self.client;

  let ready = _.Consequence();

  client.capabilityCheck({ optional : [], required : [ 'relative_root' ] }, ( err, resp ) =>
  {
    if( !err )
    return ready.take( resp )

    client.end();
    ready.error( err );
  });

  ready.thenGive( () =>
  {
    client.command([ 'watch-project', self.filePath ], ( err, resp ) =>
    {
      ready.take( err, resp );
    });
  })

  ready.finally( ( err, resp ) =>
  {
    if ( err )
    throw _.err( 'Error initiating watch:', err );

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

    self.watch = resp.watch;
    self.clock = resp.clock;
    self.relative_path = resp.relative_path;

    return self;
  })

  ready.thenGive( () =>
  {
    let sub =
    {
      expression: [ 'allof', ['match', '*' ] ],
      fields: [ 'name', 'size', 'exists', 'type' ],
      relative_path : self.relative_path
    };

    client.command([ 'subscribe', self.watch, 'mysubscription', sub ], ready.tolerantCallback() )
  })

  ready.then( () =>
  {
    client.on( 'subscription', ( resp ) =>
    {
      if( resp.canceled )
      return;

      if( resp.subscription === 'mysubscription' )
      if( !resp.is_fresh_instance )
      {
        _.event.eventGive( self.ehandler, { event : 'change', args : [ resp ] } )
        // resp.files.forEach( ( file ) =>
        // {
        //   console.log( file )
        // });
      }
    });

    return null;
  })

  return ready;
}

//

function disable()
{
  let self = this;
  let ready = _.take( null );

  ready.thenGive( () => self.client.command( [ 'watch-del-all' ], ready.tolerantCallback() ) );
  ready.thenGive( () => self.client.command( [ 'shutdown-server' ], ready.tolerantCallback() ) );

  return ready;
}

//

function on()
{
  let self = this;
  let o = self.on.head( self.on, arguments );
  _.event.on( self.ehandler, o );
}

_.routine.extend( on, _.event.on )

//

function off()
{
  let self = this;
  let o = self.off.head( self.off, arguments );
  _.event.off( self.ehandler, o );
}

_.routine.extend( off, _.event.off )

//

let Interface =
{
  enable,
  disable,

  on,
  off,

  ehandler :
  {
    events : { 'change' : [] }
  },

  filePath : null,
}

//

function watch( filePath )
{
  _.assert( arguments.length === 1 );

  // filePath = _.path.map.from( filePath );

  if( Watchman === null )
  Watchman = require( 'fb-watchman' );

  var client = new Watchman.Client();

  let o2 = Object.create( Interface );

  o2.filePath = filePath;
  o2.client = client;

  return o2;
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
