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
  var watcher = await _.files.watcher.fs.watch( a.fileProvider.path.dir( filePath ), { onChange, manager } );
  var onIdleReady = _.Consequence();
  manager.onIdle( context.t1, () =>
  {
    onIdleReady.take( null );
  })
  await onIdleReady;
  await watcher.close();
  test.identical( onIdleReady.resourcesCount(), 0 );
  manager.finit();

  /* - */

  test.case = 'single change, then idle'
  var filePath = a.abs( 'file' );
  a.fileProvider.dirMake( a.fileProvider.path.dir( filePath ) )
  await _.time.out( context.t1 );
  var manager = new _.files.watcher.manager();
  var watcher = await _.files.watcher.fs.watch( a.fileProvider.path.dir( filePath ), { onChange, manager } );
  var onIdleReady = _.Consequence();
  manager.onIdle( context.t1, () =>
  {
    onIdleReady.take( null );
  })
  a.fileProvider.fileWrite( filePath, filePath );
  await onIdleReady;
  await watcher.close();
  test.identical( onIdleReady.resourcesCount(), 0 );
  manager.finit();

  /* - */

  test.case = 'two changes, then idle'
  var filePath = a.abs( 'file' );
  a.fileProvider.dirMake( a.fileProvider.path.dir( filePath ) )
  await _.time.out( context.t1 );
  var manager = new _.files.watcher.manager();
  var watcher = await _.files.watcher.fs.watch( a.fileProvider.path.dir( filePath ), { onChange, manager } );
  var onIdleReady = _.Consequence();
  manager.onIdle( context.t1, () =>
  {
    onIdleReady.take( null );
  })
  a.fileProvider.fileWrite( filePath, filePath + 1 );
  await _.time.out( context.t1 );
  a.fileProvider.fileWrite( filePath, filePath + 2 );
  await onIdleReady;
  await watcher.close();
  test.identical( onIdleReady.resourcesCount(), 0 );
  manager.finit();

  /* */

  test.case = 'two changes, second change after delay'
  var filePath = a.abs( 'file' );
  a.fileProvider.dirMake( a.fileProvider.path.dir( filePath ) )
  await _.time.out( context.t1 );
  var manager = new _.files.watcher.manager();
  var watcher = await _.files.watcher.fs.watch( a.fileProvider.path.dir( filePath ), { onChange, manager } );
  var onIdleReady = _.Consequence();
  manager.onIdle( context.t1, () =>
  {
    onIdleReady.take( null );
  })
  a.fileProvider.fileWrite( filePath, filePath + 1 );
  await _.time.out( context.t3 );
  a.fileProvider.fileWrite( filePath, filePath + 2 );
  await onIdleReady;
  await watcher.close();
  test.identical( onIdleReady.resourcesCount(), 0 );
  manager.finit();

  /* - */

  test.case = 'three changes, idle between changes'
  var filePath = a.abs( 'file' );
  a.fileProvider.dirMake( a.fileProvider.path.dir( filePath ) )
  await _.time.out( context.t1 );
  var manager = new _.files.watcher.manager();
  var watcher = await _.files.watcher.fs.watch( a.fileProvider.path.dir( filePath ), { onChange, manager } );
  var onIdleReady = _.Consequence();
  manager.onIdle( context.t1, () =>
  {
    onIdleReady.take( null );
  })
  a.fileProvider.fileWrite( filePath, filePath + 1 );
  await _.time.out( context.t3 );
  a.fileProvider.fileWrite( filePath, filePath + 2 );
  await _.time.out( context.t3 );
  a.fileProvider.fileWrite( filePath, filePath + 3 );
  await onIdleReady;
  await watcher.close();
  test.identical( onIdleReady.resourcesCount(), 0 );
  manager.finit();

  /* - */

  test.case = 'several changes, small delay between changes'
  var filePath = a.abs( 'file' );
  a.fileProvider.dirMake( a.fileProvider.path.dir( filePath ) )
  await _.time.out( context.t1 );
  var manager = new _.files.watcher.manager();
  var watcher = await _.files.watcher.fs.watch( a.fileProvider.path.dir( filePath ), { onChange, manager } );
  var onIdleReady = _.Consequence();
  manager.onIdle( context.t1, () =>
  {
    onIdleReady.take( null );
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
  await onIdleReady;
  await watcher.close();
  test.identical( onIdleReady.resourcesCount(), 0 );
  manager.finit();

  /* - */

  test.case = 'delay before change'
  var filePath = a.abs( 'file' );
  a.fileProvider.dirMake( a.fileProvider.path.dir( filePath ) )
  await _.time.out( context.t1 );
  var manager = new _.files.watcher.manager();
  var watcher = await _.files.watcher.fs.watch( a.fileProvider.path.dir( filePath ), { onChange, manager } );
  var onIdleReady = _.Consequence();
  manager.onIdle( context.t1, () =>
  {
    onIdleReady.take( null );
  })
  await _.time.out( context.t3 );
  a.fileProvider.fileWrite( filePath, filePath + 1 );
  await onIdleReady;
  test.identical( onIdleReady.resourcesCount(), 0 );
  await watcher.close();
  manager.finit();

  /* - */

  return null;

  /* */

  function onChange()
  {
  }
}

//

async function onIdleMultipleCallbacks( test )
{
  let context = this;
  let a = test.assetFor( false );

  /* - */

  test.case = 'two idle callbacks'
  var filePath = a.abs( 'file' );
  a.fileProvider.dirMake( a.fileProvider.path.dir( filePath ) )
  await _.time.out( context.t1 );
  var manager = new _.files.watcher.manager();
  var watcher = await _.files.watcher.fs.watch( a.fileProvider.path.dir( filePath ), { onChange, manager } );
  var onIdleReady1 = _.Consequence();
  var time1,time2,time3
  manager.onIdle( context.t3, () =>
  {
    time2 = _.time.now();
    onIdleReady1.take( null );
  })
  var onIdleReady2 = _.Consequence();
  manager.onIdle( context.t3, () =>
  {
    time3 = _.time.now();
    onIdleReady2.take( null );
  })
  time1 = _.time.now();
  a.fileProvider.fileWrite( filePath, filePath + 1 );
  await _.Consequence.AndTake( onIdleReady1, onIdleReady2 );
  test.gt( time2, time1 );
  test.gt( time3, time1 );
  await watcher.close();
  test.identical( onIdleReady1.resourcesCount(), 0 );
  test.identical( onIdleReady2.resourcesCount(), 0 );
  manager.finit();

  /* - */

  return null;

  /* - */

  function onChange()
  {
  }
}

onIdleMultipleCallbacks.timeOut = 20000;

//

async function exportString( test )
{
  let context = this;
  let a = test.assetFor( false );

  /* - */

  var filePath1 = a.abs( 'a/b' )
  var filePath2 = a.abs( 'c/d' )
  a.fileProvider.fileWrite( filePath1, filePath1 )
  a.fileProvider.fileWrite( filePath2, filePath2 )
  var manager = new _.files.watcher.manager();
  var w1 = await _.files.watcher.fs.watch( filePath1, { onChange, manager } );
  var w2 = await _.files.watcher.fs.watch( [ filePath1, filePath2 ], { onChange, manager } );
  var it = manager.exportString({ verbosity : 2 });
  console.log( it.result )
  test.identical( _.strCount( it.result, /WatcherManager::#in.*/ ), 1 )
  test.identical( _.strCount( it.result, / WatcherFs::#in.*/ ), 2 )
  test.identical( _.strCount( it.result, `   FilePath:` ), 2 )
  test.identical( _.strCount( it.result, `     - ${filePath1}` ), 2 )
  test.identical( _.strCount( it.result, `     - ${filePath2}` ), 1 )
  test.identical( _.strCount( it.result, `   Filter:` ), 2 )
  test.identical( _.strCount( it.result, `      null` ), 2 )
  await w1.close();
  await w2.close();
  await manager.finit();

  /* - */

  return null;

  /* */

  function onChange()
  {
  }
}

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
    onIdleMultipleCallbacks,
    exportString
  }

}

//

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();