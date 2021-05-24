( function _WatcherManager_test_s_()
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

  self.suiteTempPath = _.path.tempOpen( _.path.join( __dirname, '../..'  ), 'WatcherManager' );
  self.assetsOriginalPath = _.path.join( __dirname, '_asset' );
}

//

function onSuiteEnd()
{
  let self = this;
  _.assert( _.strHas( self.suiteTempPath, '/WatcherManager-' ) )
  _.path.tempClose( self.suiteTempPath );
}

//

async function onIdle( test )
{
  let context = this;
  let a = test.assetFor( false );

  /* - */

  test.case = 'no changes'
  var filePath = a.abs( 'file' );
  a.fileProvider.dirMake( a.fileProvider.path.dir( filePath ) )
  await _.time.out( context.t1 );
  var manager = new _.files.watcher.manager();
  var watcher = await _.files.watcher.fs.watch( a.fileProvider.path.dir( filePath ), { manager } );
  var counter = 0;
  manager.onIdle( 1000, () =>
  {
    counter += 1;
  })
  await _.time.out( context.t3 );
  test.identical( counter, 1 );
  await watcher.close();
  manager.finit();

  /* - */

  test.case = 'single change, then idle'
  var filePath = a.abs( 'file' );
  a.fileProvider.dirMake( a.fileProvider.path.dir( filePath ) )
  await _.time.out( context.t1 );
  var manager = new _.files.watcher.manager();
  var watcher = await _.files.watcher.fs.watch( a.fileProvider.path.dir( filePath ), { manager } );
  var counter = 0;
  manager.onIdle( 1000, () =>
  {
    counter += 1;
  })
  a.fileProvider.fileWrite( filePath, filePath );
  await _.time.out( context.t3 );
  test.identical( counter, 1 );
  await watcher.close();
  manager.finit();

  /* - */

  test.case = 'two changes, then idle'
  var filePath = a.abs( 'file' );
  a.fileProvider.dirMake( a.fileProvider.path.dir( filePath ) )
  await _.time.out( context.t1 );
  var manager = new _.files.watcher.manager();
  var watcher = await _.files.watcher.fs.watch( a.fileProvider.path.dir( filePath ), { manager } );
  var counter = 0;
  manager.onIdle( 1000, () =>
  {
    counter += 1;
  })
  a.fileProvider.fileWrite( filePath, filePath + 1 );
  await _.time.out( 500 );
  a.fileProvider.fileWrite( filePath, filePath + 2 );
  await _.time.out( context.t3 );
  test.identical( counter, 1 );
  await watcher.close();
  manager.finit();

  /* */

  test.case = 'two changes, second change after idle'
  var filePath = a.abs( 'file' );
  a.fileProvider.dirMake( a.fileProvider.path.dir( filePath ) )
  await _.time.out( context.t1 );
  var manager = new _.files.watcher.manager();
  var watcher = await _.files.watcher.fs.watch( a.fileProvider.path.dir( filePath ), { manager } );
  var counter = 0;
  manager.onIdle( context.t3, () =>
  {
    counter += 1;
  })
  a.fileProvider.fileWrite( filePath, filePath + 1 );
  await _.time.out( context.t3 );
  a.fileProvider.fileWrite( filePath, filePath + 2 );
  await _.time.out( context.t3 );
  test.identical( counter, 1 );
  await watcher.close();
  manager.finit();

  /* - */

  test.case = 'three changes, idle between changes'
  var filePath = a.abs( 'file' );
  a.fileProvider.dirMake( a.fileProvider.path.dir( filePath ) )
  await _.time.out( context.t1 );
  var manager = new _.files.watcher.manager();
  var watcher = await _.files.watcher.fs.watch( a.fileProvider.path.dir( filePath ), { manager } );
  var counter = 0;
  manager.onIdle( context.t3, () =>
  {
    counter += 1;
  })
  a.fileProvider.fileWrite( filePath, filePath + 1 );
  await _.time.out( context.t3 );
  a.fileProvider.fileWrite( filePath, filePath + 2 );
  await _.time.out( context.t3 );
  a.fileProvider.fileWrite( filePath, filePath + 3 );
  await _.time.out( context.t3 );
  test.identical( counter, 1 );
  await watcher.close();
  manager.finit();

  /* - */

  test.case = 'several changes, small delay between changes'
  var filePath = a.abs( 'file' );
  a.fileProvider.dirMake( a.fileProvider.path.dir( filePath ) )
  await _.time.out( context.t1 );
  var manager = new _.files.watcher.manager();
  var watcher = await _.files.watcher.fs.watch( a.fileProvider.path.dir( filePath ), { manager } );
  var counter = 0;
  manager.onIdle( 1000, () =>
  {
    counter += 1;
  })
  var cons = [];
  var times = 5;
  for( let i = 0; i < times; i++ )
  {
    let con = _.time.out( _.intRandom([ 0, 500 ]), () =>
    {
      a.fileProvider.fileWrite( filePath, filePath );
      return null;
    })
    cons.push( con );
  }
  await _.Consequence.AndKeep( ... cons );
  await _.time.out( context.t3 );
  test.identical( counter, 1 );
  await watcher.close();
  manager.finit();

  /* - */

  test.case = 'delay before change'
  var filePath = a.abs( 'file' );
  a.fileProvider.dirMake( a.fileProvider.path.dir( filePath ) )
  await _.time.out( context.t1 );
  var manager = new _.files.watcher.manager();
  var watcher = await _.files.watcher.fs.watch( a.fileProvider.path.dir( filePath ), { manager } );
  var counter = 0;
  manager.onIdle( context.t3, () =>
  {
    counter += 1;
  })
  await _.time.out( context.t3 );
  a.fileProvider.fileWrite( filePath, filePath + 1 );
  test.identical( counter, 1 );
  await watcher.close();
  manager.finit();

  /* - */

  return null;
}

//

async function onIdleMultipleCallbacks( test )
{
  let context = this;
  let a = test.assetFor( false );

  /* - */

  test.case = 'two callback with different timeouts'
  var filePath = a.abs( 'file' );
  a.fileProvider.dirMake( a.fileProvider.path.dir( filePath ) )
  await _.time.out( context.t1 );
  var manager = new _.files.watcher.manager();
  var watcher = await _.files.watcher.fs.watch( a.fileProvider.path.dir( filePath ), { manager } );
  var counter = [ 0, 0 ]
  manager.onIdle( context.t3, () =>
  {
    counter[ 0 ] += 1;
  })
  manager.onIdle( context.t3 * 2, () =>
  {
    counter[ 1 ] += 1;
  })
  a.fileProvider.fileWrite( filePath, filePath + 1 );
  await _.time.out( context.t1 * 5 );
  a.fileProvider.fileWrite( filePath, filePath + 2 );
  await _.time.out( context.t1 * 10 );
  test.identical( counter, [ 1, 1 ] );
  await watcher.close();
  manager.finit();

  /* - */

  return null;
}

onIdleMultipleCallbacks.timeOut = 20000;

// --
// declare
// --

const Proto =
{

  name : 'Tools.files.watcher.manager',
  silencing : 1,

  onSuiteBegin,
  onSuiteEnd,
  routineTimeOut : 60000,

  context :
  {
    suiteTempPath : null,
    assetsOriginalPath : null,
    t1 : 1000,
    t3 : 3000
  },

  tests :
  {
    onIdle,
    onIdleMultipleCallbacks
  }

}

//

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();