( function _Watcher_test_s_()
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
}

//

function onSuiteEnd()
{
  let self = this;
  _.assert( _.strHas( self.suiteTempPath, '.tmp' ) )
  _.path.tempClose( self.suiteTempPath );
}

//


async function terminalFile( test )
{
  let context = this;
  let a = test.assetFor( false );

  /* - */

  test.case = 'create'
  var filePath = a.abs( 'file.js' );
  a.fileProvider.dirMake( a.fileProvider.path.dir( filePath ) )
  await _.time.out( context.t1 );
  var watcher = await context.watcher.watch( a.fileProvider.path.dir( filePath ) );
  var eventReady = _.Consequence();
  watcher.once( 'change', ( e ) =>
  {
    eventReady.take( e )
  })
  a.fileProvider.fileWrite( filePath, 'a' );
  var e = await eventReady;
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
  await _.time.out( context.t1 );
  var watcher = await context.watcher.watch( a.fileProvider.path.dir( filePath ) );
  var eventReady = _.Consequence();
  watcher.once( 'change', ( e ) =>
  {
    eventReady.take( e )
  })
  a.fileProvider.fileWrite( filePath, 'ab' );
  var e = await eventReady;
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
  await _.time.out( context.t1 );
  var watcher = await context.watcher.watch( a.fileProvider.path.dir( filePath ) );
  var eventReady = _.Consequence();
  var events = [];
  watcher.on( 'change', ( e ) =>
  {
    events.push( e );
    if( events.length > 1 )
    eventReady.take( null )
  })
  a.fileProvider.fileRename( filePath2, filePath );
  await eventReady;
  var exp =
  [{
    filePath : 'file.js',
    watchPath : a.fileProvider.path.dir( filePath ),
  }]
  test.contains( events[ 0 ].files, exp )
  var exp =
  [{
    filePath : 'file.x',
    watchPath : a.fileProvider.path.dir( filePath ),
  }]
  test.contains( events[ 1 ].files, exp )
  await watcher.close();

  /* - */

  test.case = 'delete'
  var filePath = a.abs( 'file.js' );
  a.fileProvider.fileWrite( filePath, 'a' );
  await _.time.out( context.t1 );
  var watcher = await context.watcher.watch( a.fileProvider.path.dir( filePath ) );
  var eventReady = _.Consequence();
  watcher.once( 'change', ( e ) =>
  {
    eventReady.take( e )
  })
  a.fileProvider.filesDelete( filePath );
  var e = await eventReady;
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
  let context = this;
  let a = test.assetFor( false );

  /* - */

  test.case = 'create'
  var filePath = a.abs( 'create/dir' );
  a.fileProvider.dirMake( a.fileProvider.path.dir( filePath ) )
  var watcher = await context.watcher.watch( a.fileProvider.path.dir( filePath ) );
  var eventReady = _.Consequence();
  watcher.once( 'change', ( e ) =>
  {
    eventReady.take( e )
  })
  a.fileProvider.dirMake( filePath );
  var e = await eventReady;
  var exp =
  [{
    filePath : 'dir',
    watchPath : a.fileProvider.path.dir( filePath ),
  }]
  test.contains( e.files, exp )
  await watcher.close();

  /* - */

  test.case = 'rename'
  var filePath = a.abs( 'rename/dira' );
  var filePath2 = a.abs( 'rename/dirb' );
  a.fileProvider.dirMake( filePath )
  await _.time.out( context.t1 );
  var watcher = await context.watcher.watch( a.fileProvider.path.dir( filePath ) );
  var events = [];
  var eventReady = _.Consequence();
  watcher.on( 'change', ( e ) =>
  {
    events.push( e );
    if( events.length > 1 )
    eventReady.take( null )
  })
  a.fileProvider.fileRename( filePath2, filePath );
  await eventReady;
  var exp =
  [{
    filePath : 'dira',
    watchPath : a.fileProvider.path.dir( filePath ),
  }]
  test.contains( events[ 0 ].files, exp )
  var exp =
  [{
    filePath : 'dirb',
    watchPath : a.fileProvider.path.dir( filePath ),
  }]
  test.contains( events[ 1 ].files, exp )
  await watcher.close();

  /* - */

  test.case = 'delete'
  var filePath = a.abs( 'delete/dir' );
  a.reflect();
  a.fileProvider.dirMake( filePath )
  await _.time.out( context.t1 );
  var watcher = await context.watcher.watch( a.fileProvider.path.dir( filePath ) );
  var eventReady = _.Consequence();
  watcher.once( 'change', ( e ) =>
  {
    eventReady.take( e )
  })
  a.fileProvider.filesDelete( filePath );
  var e = await eventReady;
  var exp =
  [{
    filePath : 'dir',
    watchPath : a.fileProvider.path.dir( filePath ),
  }]
  test.contains( e.files, exp )
  await watcher.close();

  /* - */

  return null;
}

//

async function filePathIsMissing( test )
{
  let context = this;
  let a = test.assetFor( false );

  /* - */

  test.case = 'disabled'
  var filePath = a.abs( 'create/dir' );
  var watcher = await test.mustNotThrowError( () => context.watcher.watch( filePath, { enabled : 0 } ) )
  await test.mustNotThrowError( () => watcher.close() );

  /* - */

  test.case = 'enabled'
  var filePath = a.abs( 'create/dir' );
  await test.shouldThrowErrorAsync( context.watcher.watch( filePath, { enabled : 1 } ) );

  /* - */

  test.case = 'enabled later'
  var filePath = a.abs( 'create/dir' );
  var watcher = await context.watcher.watch( filePath, { enabled : 0 } );
  await test.shouldThrowErrorAsync( watcher.resume() );

  /* - */

  test.case = 'multiple paths, one is missing'
  var filePath = a.abs( 'create/dir1' );
  var filePath2 = a.abs( 'create/dir2' );
  a.fileProvider.dirMake( filePath );
  var watcher = await context.watcher.watch( [ filePath, filePath2 ], { enabled : 0 } );
  await test.shouldThrowErrorAsync( watcher.resume() );

  /* - */

  return null;
}

//

async function close( test )
{
  let context = this;
  let a = test.assetFor( false );

  /* - */

  test.case = 'no events after close'
  var filePath = a.abs( 'create/dir' );
  a.fileProvider.dirMake( a.fileProvider.path.dir( filePath ) )
  var watcher = await context.watcher.watch( a.fileProvider.path.dir( filePath ) );
  test.true( watcher.manager.has( watcher ) );
  var eventReady = _.Consequence();
  watcher.once( 'change', ( e ) => eventReady.take( e ) )
  await watcher.close();
  a.fileProvider.dirMake( filePath );
  await _.time.out( context.t3 );
  test.identical( eventReady.resourcesCount(), 0 );
  test.true( watcher.closed );
  test.false( watcher.manager.has( watcher ) );

  /* - */

  test.case = 'call close twice'
  var filePath = a.abs( 'create/dir' );
  a.fileProvider.dirMake( a.fileProvider.path.dir( filePath ) )
  var watcher = await context.watcher.watch( a.fileProvider.path.dir( filePath ) );
  test.true( watcher.manager.has( watcher ) );
  var eventReady = _.Consequence();
  await watcher.close();
  await test.mustNotThrowError( watcher.close() );
  test.true( watcher.closed );
  test.false( watcher.manager.has( watcher ) );

  /* - */

  return null;
}

// --
// declare
// --

const Proto =
{

  name : 'Tools.files.watcher.abstract',
  silencing : 1,

  abstract : 1,

  onSuiteBegin,
  onSuiteEnd,
  routineTimeOut : 60000,

  context :
  {
    suiteTempPath : null,
    assetsOriginalPath : null,
    t1 : 1000,
    t3 : 3000,
    watcher : null
  },

  tests :
  {
    terminalFile,
    directory,

    filePathIsMissing,
    // filePathRenamed
    // filePathReaddedSame,
    // filePathReaddedDifferent,
    // filePathReplacedFileByDir,
    // filePathReplacedDirByFile,
    // filePathReplacedFileByLink,
    // filePathReplacedDirByLink,
    // filePathMultiple,
    // filePathIsSoftLinkToFile,
    // filePathIsSoftLinkToDir,
    // filePathIsHardLink,
    // filePathSingleLevelTree,
    // filePathMultilevelTree
    // filePathDeleteAfterStartTerminal,
    // filePathDeleteAfterStartSimpleTree,
    // filePathDeleteAfterStartComplexTree,
    // watchFollowingSymlinks

    close,
  }

}

//

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();