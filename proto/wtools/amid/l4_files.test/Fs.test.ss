( function _FsWatcher_test_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( 'Tools' );

  _.include( 'wTesting' );;
  _.include( 'wProcess' );
  _.include( 'wFiles' );

  require( '../l4_files/l7_watcher/include/Top.s' );

}

const _global = _global_;
const _ = _global_.wTools;

// --
// context
// --

function onSuiteBegin()
{
  let self = this;

  self.suiteTempPath = _.path.tempOpen( _.path.join( __dirname, '../..'  ), 'FsWatcher' );
  self.assetsOriginalPath = _.path.join( __dirname, '_asset' );
}

//

function onSuiteEnd()
{
  let self = this;
  _.assert( _.strHas( self.suiteTempPath, '/FsWatcher-' ) )
  _.path.tempClose( self.suiteTempPath );
}

//

async function terminalFile( test )
{
  let a = test.assetFor( false );

  /* - */

  test.case = 'create'
  var filePath = a.abs( 'file.js' );
  var ready = _.Consequence();
  a.fileProvider.dirMake( a.fileProvider.path.dir( filePath ) )
  var watcher = await _.files.watcher.fs.watch( a.fileProvider.path.dir( filePath ) );
  watcher.on( 'change', ( e ) => ready.take( e ) );
  a.fileProvider.fileWrite( filePath, 'a' );
  var e = await ready;
  var exp =
  [{
    filePath : 'file.js',
    watchPath : a.fileProvider.path.dir( filePath ),
  }]
  test.contains( e.files, exp )
  await watcher.close();

  /* - */

  test.case = 'change'
  var filePath = a.abs( 'file.js' );
  a.fileProvider.fileWrite( filePath, 'a' );
  var ready = _.Consequence();
  var watcher = await _.files.watcher.fs.watch( a.fileProvider.path.dir( filePath ) );
  watcher.on( 'change', ( e ) => ready.take( e ) );
  a.fileProvider.fileWrite( filePath, 'ab' );
  var e = await ready;
  var exp =
  [{
    filePath : 'file.js',
    watchPath : a.fileProvider.path.dir( filePath ),
  }]
  test.contains( e.files, exp )
  await watcher.close();

  /* - */

  test.case = 'rename'
  var filePath = a.abs( 'file.js' );
  var filePath2 = a.abs( 'file.x' );
  a.fileProvider.fileWrite( filePath, 'a' );
  var ready = _.Consequence();
  var watcher = await _.files.watcher.fs.watch( a.fileProvider.path.dir( filePath ) );
  watcher.on( 'change', ( e ) => ready.take( e ) )
  a.fileProvider.fileRename( filePath2, filePath );
  var e = await ready;
  var exp =
  [{
    filePath : 'file.js',
    watchPath : a.fileProvider.path.dir( filePath ),
  }]
  test.contains( e.files, exp )
  await watcher.close();

  /* - */

  test.case = 'delete'
  var filePath = a.abs( 'file.js' );
  a.fileProvider.fileWrite( filePath, 'a' );
  var ready = _.Consequence();
  var watcher = await _.files.watcher.fs.watch( a.fileProvider.path.dir( filePath ) );
  watcher.on( 'change', ( e ) => ready.take( e ) )
  a.fileProvider.filesDelete( filePath );
  var e = await ready;
  var exp =
  [{
    filePath : 'file.js',
    watchPath : a.fileProvider.path.dir( filePath ),
  }]
  test.contains( e.files, exp )
  await watcher.close();

  /* - */

  return null;
}

//

async function directory( test )
{
  let a = test.assetFor( false );

  /* - */

  test.case = 'create'
  var filePath = a.abs( 'dir' );
  var ready = _.Consequence();
  a.reflect();
  a.fileProvider.dirMake( a.fileProvider.path.dir( filePath ) )
  var watcher = await _.files.watcher.fs.watch( a.fileProvider.path.dir( filePath ) );
  watcher.on( 'change', ( e ) => ready.take( e ) );
  a.fileProvider.dirMake( filePath );
  var e = await ready;
  var exp =
  [{
    filePath : 'dir',
    watchPath : a.fileProvider.path.dir( filePath ),
  }]
  test.contains( e.files, exp )
  await watcher.close();

  /* - */

  test.case = 'rename'
  var filePath = a.abs( 'dira' );
  var filePath2 = a.abs( 'dirb' );
  var ready = _.Consequence();
  a.reflect();
  a.fileProvider.dirMake( filePath )
  var watcher = await _.files.watcher.fs.watch( a.fileProvider.path.dir( filePath ) );
  watcher.on( 'change', ( e ) => ready.take( e ) )
  a.fileProvider.fileRename( filePath2, filePath );
  var e = await ready;
  var exp =
  [{
    filePath : 'dira',
    watchPath : a.fileProvider.path.dir( filePath ),
  }]
  test.contains( e.files, exp )
  await watcher.close();

  /* - */

  test.case = 'delete'
  var filePath = a.abs( 'dirToDelete' );
  var ready = _.Consequence();
  a.reflect();
  a.fileProvider.dirMake( filePath )
  var watcher = await _.files.watcher.fs.watch( a.fileProvider.path.dir( filePath ) );
  watcher.on( 'change', ( e ) => ready.take( e ) )
  a.fileProvider.filesDelete( filePath );
  var e = await ready;
  var exp =
  [{
    filePath : 'dirToDelete',
    watchPath : a.fileProvider.path.dir( filePath ),
  }]
  test.contains( e.files, exp )
  await watcher.close();

  /* - */

  return null;
}

// --
// declare
// --

const Proto =
{

  name : 'Tools.files.watcher.fs',
  silencing : 1,

  onSuiteBegin,
  onSuiteEnd,
  routineTimeOut : 60000,

  context :
  {
    suiteTempPath : null,
    assetsOriginalPath : null,
  },

  tests :
  {
    terminalFile,
    directory
  }

}

//

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();