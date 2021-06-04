( function _Watcher_s_()
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
// _.files.watcher.abstract = _.files.watcher.abstract || Object.create( null );

// --
// implementation
// --

const Parent = null;
const Self = Watcher;
function Watcher( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'Watcher';

//

function finit()
{
  if( this.formed )
  this.unform();
  _.Copyable.prototype.finit.apply( this, arguments );
  self.manager.eventGive
  ({
    kind : 'watcher.init',
    watcher : self,
  })
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

  self.manager.eventGive
  ({
    kind : 'watcher.init',
    watcher : self,
  })
}

//

function unform()
{
  let self = this;

  _.assert( arguments.length === 0, 'Expects no arguments' );
  _.assert( !!self.formed );

  /* begin */

  self.manager._remove( self );

  /* end */

  self.formed = 0;
  return self;
}

//

function form()
{
  let self = this;

  if( self.manager === null )
  self.manager = _.files.watcher.defaultManager;

  _.assert( self.manager instanceof _.files.watcher.manager )

  self.manager._add( self );

  self.filePath = _.path.mapsPair( null, self.filePath );

  if( self.filter )
  {
    self.filter = _.array.as( self.filter );
    _.assert( _.strsAreAll( self.filter ) );
    self.filter = self.filter.map( ( e ) => _.path.globShortSplitToRegexp( e ) )
    self.logic = _.logic.or( self.filter );
  }

  self.formed = 1;
  return self;
}

//

function featuresForm()
{
  let self = this;
  let features = self.Features;

  let ready = _.take( self );

  if( features._formed )
  return ready;

  ready.then( () => self._featuresForm() )

  return ready;
}

//

function resume()
{
  let self = this;

  let ready = self.featuresForm();

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
    self.manager._remove( self );
    self.enabled = false;
    self.closed = true;
    return self;
  });

  return ready;
}

//

// function on()
// {
//   let self = this;
//   let o = self.on.head( self.on, arguments );
//   _.event.on( self.ehandler, o );
// }

// _.routine.extend( on, _.event.on )

//

// function off()
// {
//   let self = this;
//   let o = self.off.head( self.off, arguments );
//   _.event.off( self.ehandler, o );
// }

// _.routine.extend( off, _.event.off )

// --
// extension
// --

let Features =
{
  recursion : null,
  watchedDirRenameDetection : null,
  _formed : 0
}

//

let Composes =
{
  filePath : null,
  filter : null
}

//

let Associates =
{
  manager : null,
  onChange : null,
  onError : null,
}

//

let Restricts =
{
  enabled : 0,
  paused : 0,
  closed : 0,

  formed : 0,

  logic : null,
}

let Statics =
{
  Features
}

// let Events =
// {
//   'change' : 'change',
//   'error' : 'error',
// }

//

let Extension =
{
  finit,
  init,
  unform,
  form,

  featuresForm,
  _featuresForm : null,

  resume,
  _resume : null,
  pause,
  _pause : null,
  close,
  _close : null,

  Composes,
  Associates,
  Restricts,
  Statics
  // Events
}

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Extension,
});

_.Copyable.mixin( Self );
// _.EventHandler.mixin( Self );

_.files.watcher.abstract = Self;

})();
