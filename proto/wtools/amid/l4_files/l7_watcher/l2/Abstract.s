( function _Abstract_s_()
{

'use strict';

/**
 * @namespace Tools.files.watcher.abstract
 * @module Tools/mid/FilesWather
 */


const _global = _global_;
const _ = _global_.wTools;
_.assert( !!_.files.watcher );
_.assert( !_.files.watcher.abstract );
_.files.watcher.abstract = _.files.watcher.abstract || Object.create( null );

// --
// implementation
// --

function resume()
{
  let self = this;

  let ready = _.take( self );

  if( self.enabled && !self.paused )
  return ready;

  ready.then( () => self._resume() )

  ready.then( () =>
  {
    self.paused = false;
    return self;
  })

  return ready;
}

//

function pause()
{
  let self = this;
  let ready = _.take( self );

  if( self.paused )
  return ready;

  ready.then( () => self._pause() )

  ready.then( () =>
  {
    self.paused = true;
    return self;
  })

  return ready;
}

//

function close()
{
  let self = this;

  let ready = _.take( self );

  if( !self.enabled )
  return ready;

  ready.then( () => self._close() )

  ready.then( () =>
  {
    _.each( self.ehandler.events, ( e, k ) => self.off( k ) );
    _.arrayRemoveElementOnceStrictly( _.files.watcher.watcherArray, self );
    self.enabled = false;
    self.closed = true;
    return self;
  });

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

// --
// extension
// --

let Extension =
{
  resume,
  _resume : null,
  pause,
  _pause : null,
  close,
  _close : null,

  on,
  off,

  enabled : 0,
  paused : 0,
  closed : 0,

  filePath : null,

  ehandler :
  {
    events : { 'change' : [] }
  }

}

Object.assign( _.files.watcher.abstract, Extension );

})();
