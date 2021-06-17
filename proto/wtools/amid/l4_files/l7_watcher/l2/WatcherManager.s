( function _WatcherManager_s_()
{

'use strict';

/**
 * @namespace Tools.files.watcher.manager
 * @module Tools/mid/FilesWather
 */


const _global = _global_;
const _ = _global_.wTools;
_.assert( !!_.files.watcher );
_.assert( !_.files.watcher.manager );

// --
// implementation
// --

const Parent = null;
const Self = WatcherManager;
function WatcherManager( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'WatcherManager';

//

function finit()
{
  if( this.formed )
  this.unform();
  return _.Copyable.prototype.finit.apply( this, arguments );
}

//

function init( o )
{
  let self = this;

  _.workpiece.initFields( self );
  Object.preventExtensions( self );

  if( o )
  self.copy( o );

  self.form();
}

//

function unform()
{
  let self = this;

  _.assert( arguments.length === 0, 'Expects no arguments' );
  _.assert( !!self.formed );

  /* begin */

  _.assert( self.watcherArray.length === 0, 'Watchers are not closed.' )
  _.arrayRemoveElementOnceStrictly( _.files.watcher.managerArray, self );

  self.idleTimers.forEach( ( timer ) => timer.cancel() )
  _.longEmpty( self.idleTimers );

  /* end */

  self.formed = 0;
  return self;
}

//

function form()
{
  let self = this;

  _.arrayAppendElementOnceStrictly( _.files.watcher.managerArray, self );

  self.formed = 1;
  return self;
}

//

function _add( watcher )
{
  let self = this;
  _.assert( watcher instanceof _.files.watcher.abstract );
  _.assert( !_.longHas( self.watcherArray, watcher ) );
  _.arrayAppendElement( self.watcherArray, watcher );
}

//

function _remove( watcher )
{
  let self = this;
  _.assert( watcher instanceof _.files.watcher.abstract );
  _.assert( _.longHas( self.watcherArray, watcher ) );
  _.arrayRemoveElement( self.watcherArray, watcher );
}

//

function has( watcher )
{
  let self = this;
  _.assert( watcher instanceof _.files.watcher.abstract );
  return _.longHas( self.watcherArray, watcher );
}

//

function pause()
{
  let self = this;

  if( !self.watcherArray.length )
  return _.take( null );

  let cons = self.watcherArray.map( ( watcher ) => watcher.pause() );
  return _.Consequence.AndKeep( ... cons );
}

//

function resume()
{
  let self = this;

  if( !self.watcherArray.length )
  return _.take( null );

  let cons = self.watcherArray.map( ( watcher ) => watcher.resume() );
  return _.Consequence.AndKeep( ... cons );
}

//

function close()
{
  let self = this;

  if( !self.watcherArray.length )
  return _.take( null );

  let cons = self.watcherArray.map( ( watcher ) => watcher.close() );
  let ready = _.Consequence.AndKeep( ... cons );

  ready.then( () =>
  {
    _.longEmpty( self.watcherArray );
    return self;
  })

  return ready;
}

//

function _onChange( e )
{
  let self = this;

  self.eventGive( e );

  self.idleTimers.forEach( ( timer ) => timer.cancel() )
  _.longEmpty( self.idleTimers );

  self.idleTimerDescriptors.forEach( ( descriptor ) =>
  {
    let timer = _.time.begin( descriptor.time, () =>
    {
      _.arrayRemoveElementOnceStrictly( self.idleTimerDescriptors, descriptor )
      _.arrayRemoveElementOnceStrictly( self.idleTimers, timer )
      descriptor.cb();
    })
    self.idleTimers.push( timer );
  })
}

//

function _onError( e )
{
  let self = this;
  self.eventGive( e );
}

//

function onIdle( time, cb )
{
  let self = this;

  _.assert( arguments.length === 2 );
  _.assert( _.numberIs( time ) );
  _.assert( _.routineIs( cb ) );

  let descriptor = { time, cb };
  self.idleTimerDescriptors.push( descriptor );

  let timer = _.time.begin( descriptor.time, () =>
  {
    _.arrayRemoveElementOnceStrictly( self.idleTimerDescriptors, descriptor )
    _.arrayRemoveElementOnceStrictly( self.idleTimers, timer )
    descriptor.cb();
  })
  self.idleTimers.push( timer );
}

//

function exportString( o )
{
  let self = this;

  o = _.routine.options( exportString, o || null );

  let it = o.it = _.stringer.it( o.it || { verbosity : 2 } );
  it.opts = o;

  if( o.withName === null )
  o.withName = 1;

  if( o.withName )
  it.iterator.result += self.qualifiedName;

  if( it.verbosity >= 1 )
  {
    if( o.withName )
    it.tabLevelUp();

    let watcherArray = self.watcherArray.slice();
    _.each( watcherArray, ( watcher ) =>
    {
      it.lineWrite( '' );
      watcher.exportString( o );
    })

    if( o.withName )
    it.tabLevelDown();
  }

  return it;
}

exportString.defaults =
{
  verbosity : 1,
  withName : null,
  it : null,
}

//

// --
// extension
// --

let Composes =
{
}

//

let Associates =
{
}

//

let Restricts =
{
  watcherArray : _.define.own( [] ),
  lastEventTime : null,
  idleTimers : _.define.own( [] ),
  idleTimerDescriptors : _.define.own( [] ),

  formed : 0
}

//

let Events =
{
  'file.change' : 'file.change',
  'watcher.init' : 'watcher.init',
  'watcher.finit' : 'watcher.finit',
  'error' : 'error',
}

//

let Extension =
{
  finit,
  init,
  unform,
  form,

  _add,
  _remove,
  has,

  pause,
  resume,

  close,

  _onChange,
  _onError,

  onIdle,

  exportString,

  Composes,
  Associates,
  Restricts,
  Events
}

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Extension,
});

_.Copyable.mixin( Self );
_.EventHandler.mixin( Self );
_.Instancing.mixin( Self );

//

_.files.watcher.manager = Self;
_.files.watcher.defaultManager = new Self();

_.assert( _.files.watcher.defaultManager instanceof Self );

})();
