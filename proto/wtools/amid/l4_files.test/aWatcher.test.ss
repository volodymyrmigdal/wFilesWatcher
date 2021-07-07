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
  var eventReady = _.Consequence();
  var files = [];
  var watcher = await context.watcher.watch( a.fileProvider.path.dir( filePath ), ( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) );
    files.push( ... e.files );
    if( files.length === 1 )
    eventReady.take( e )
  });
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
  var eventReady = _.Consequence();
  var watcher = await context.watcher.watch( a.fileProvider.path.dir( filePath ),( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) );
    eventReady.take( e )
  });
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
  var filePath = a.abs( 'src' );
  var filePath2 = a.abs( 'dst' );
  a.fileProvider.fileWrite( filePath, 'src' );
  await _.time.out( context.t1 );
  var eventReady = _.Consequence();
  var files = [];
  var watcher = await context.watcher.watch( a.fileProvider.path.dir( filePath ), ( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) );
    files.push( ... e.files );
    if( files.length === 2 )
    eventReady.take( null )
  });
  a.fileProvider.fileRename( filePath2, filePath );
  await eventReady;
  var fileNames = files.map( ( file ) => a.fileProvider.path.fullName( file.filePath ) );
  test.true( _.longHas( fileNames, 'src' ) )
  test.true( _.longHas( fileNames, 'dst' ) )
  await watcher.close();

  /* - */

  test.case = 'delete'
  var filePath = a.abs( 'file.js' );
  a.fileProvider.fileWrite( filePath, 'a' );
  await _.time.out( context.t1 );
  var eventReady = _.Consequence();
  var watcher = await context.watcher.watch( a.fileProvider.path.dir( filePath ),( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) );
    eventReady.take( e )
  });
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
  var eventReady = _.Consequence();
  await _.time.out( context.t1 )
  var watcher = await context.watcher.watch( a.fileProvider.path.dir( filePath ),( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) )
    eventReady.take( e )
  });
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
  var files = [];
  var eventReady = _.Consequence();
  var watcher = await context.watcher.watch( a.fileProvider.path.dir( filePath ), ( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) )
    files.push( ... e.files );
    if( files.length === 2 )
    eventReady.take( null )
  })
  a.fileProvider.fileRename( filePath2, filePath );
  await eventReady;
  var fileNames = files.map( ( file ) => a.fileProvider.path.fullName( file.filePath ) );
  test.true( _.longHas( fileNames, 'dira' ) )
  test.true( _.longHas( fileNames, 'dirb' ) )
  await watcher.close();

  /* - */

  test.case = 'delete'
  var filePath = a.abs( 'delete/dir' );
  a.reflect();
  a.fileProvider.dirMake( filePath )
  await _.time.out( context.t1 );
  var eventReady = _.Consequence();
  var watcher = await context.watcher.watch( a.fileProvider.path.dir( filePath ), ( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) )
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

async function softLinkCreate( test )
{
  let context = this;
  let a = test.assetFor( false );
  let path = a.fileProvider.path;

  /* - */

  test.case = 'create soft link'
  var filePath = a.abs( 'file.js' );
  var linkPath = a.abs( 'link.js' );
  a.fileProvider.dirMake( a.fileProvider.path.dir( filePath ) )
  a.fileProvider.fileWrite( filePath, 'file' )
  await _.time.out( context.t1 );
  var eventReady = _.Consequence();
  var watcher = await context.watcher.watch( a.fileProvider.path.dir( filePath ), ( e ) =>
  {
    eventReady.take( e )
  })
  a.fileProvider.softLink( linkPath, filePath );
  var e = await eventReady;
  var exp =
  [{
    filePath : 'link.js',
    watchPath : a.fileProvider.path.dir( filePath ),
  }]
  test.contains( e.files, exp )
  await watcher.close();

  /* - */

  return null;
}

//

async function softLinkRewrite( test )
{
  let context = this;
  let a = test.assetFor( false );
  let path = a.fileProvider.path;

  /* - */

  test.case = 'change'
  var filePath = a.abs( 'file.js' );
  var filePath2 = a.abs( 'file.js' );
  var linkPath = a.abs( 'link.js' );
  a.fileProvider.dirMake( a.fileProvider.path.dir( filePath ) )
  a.fileProvider.fileWrite( filePath, 'file' )
  a.fileProvider.fileWrite( filePath2, 'file2' )
  a.fileProvider.softLink( linkPath, filePath );
  await _.time.out( context.t1 );
  var eventReady = _.Consequence();
  var files = [];
  var watcher = await context.watcher.watch( a.fileProvider.path.dir( filePath ), ( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) )
    files.push( ... e.files )
    if( e.files[ 0 ].filePath === 'link.js' )
    eventReady.take( e )
  })
  a.fileProvider.softLink( linkPath, filePath2 );
  await eventReady;
  var fileNames = files.map( ( file ) => path.fullName( file.filePath ) )
  test.true( _.longHas( fileNames, 'link.js' ) )
  await watcher.close();

  /* - */

  return null;
}

//

async function softLinkRename( test )
{
  let context = this;
  let a = test.assetFor( false );
  let path = a.fileProvider.path;

  /* - */

  test.case = 'rename'
  var filePath = a.abs( 'file.js' );
  var linkPath = a.abs( 'link.js' );
  var linkPath2 = a.abs( 'link2.js' );
  a.fileProvider.fileWrite( filePath, 'a' );
  a.fileProvider.softLink( linkPath, filePath );
  await _.time.out( context.t1 );
  var eventReady = _.Consequence();
  var filesNames = [];
  var watcher = await context.watcher.watch( a.fileProvider.path.dir( filePath ), ( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) )
    let names = e.files.map( ( file ) => path.fullName( file.filePath ) );
    filesNames.push( ... names )
    if( _.longHas( filesNames, 'link.js' ) && _.longHas( filesNames, 'link2.js' ) )
    eventReady.take( null )
  })
  a.fileProvider.fileRename( linkPath2, linkPath );
  await eventReady;
  test.true( _.longHas( filesNames, 'link.js' ) )
  test.true( _.longHas( filesNames, 'link2.js' ) )
  await watcher.close();

  /* - */

  return null;
}

//

async function softLinkDelete( test )
{
  let context = this;
  let a = test.assetFor( false );
  let path = a.fileProvider.path;

  /* - */

  test.case = 'delete'
  var filePath = a.abs( 'file.js' );
  var linkPath = a.abs( 'link.js' );
  a.fileProvider.fileWrite( filePath, 'a' );
  a.fileProvider.softLink( linkPath, filePath );
  await _.time.out( context.t1 );
  var eventReady = _.Consequence();
  var watcher = await context.watcher.watch( a.fileProvider.path.dir( filePath ), ( e ) =>
  {
    eventReady.take( e )
  })
  a.fileProvider.filesDelete( linkPath );
  var e = await eventReady;
  var exp =
  [{
    filePath : 'link.js',
    watchPath : a.fileProvider.path.dir( filePath ),
  }]
  test.contains( e.files, exp )
  await watcher.close();

  /* - */

  return null;
}

//

async function hardLinkCreate( test ) //xxx: doesn't detect link creation on MacOS Catalina
{
  let context = this;
  let a = test.assetFor( false );
  let path = a.fileProvider.path;

  /* - */

  test.case = 'create hard link'
  var filePath = a.abs( 'file.js' );
  var linkPath = a.abs( 'link.js' );
  a.fileProvider.dirMake( a.fileProvider.path.dir( filePath ) )
  a.fileProvider.fileWrite( filePath, 'file' )
  await _.time.out( context.t1 );
  var eventReady = _.Consequence();
  var files = [];
  var watcher = await context.watcher.watch( a.fileProvider.path.dir( filePath ), ( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) );
    files.push( ... e.files )
    if( files.length === 1 )
    eventReady.take( e )
  })
  a.fileProvider.hardLink( linkPath, filePath );
  await eventReady;
  test.ge( files.length, 1 );
  await watcher.close();

  /* - */

  return null;
}

//

async function hardLinkRewrite( test )
{
  let context = this;
  let a = test.assetFor( false );
  let path = a.fileProvider.path;

  /* - */

  test.case = 'change'
  var filePath = a.abs( 'file.js' );
  var filePath2 = a.abs( 'file.js' );
  var linkPath = a.abs( 'link.js' );
  a.fileProvider.dirMake( a.fileProvider.path.dir( filePath ) )
  a.fileProvider.fileWrite( filePath, 'file' )
  a.fileProvider.fileWrite( filePath2, 'file2' )
  a.fileProvider.hardLink( linkPath, filePath );
  await _.time.out( context.t1 );
  var eventReady = _.Consequence();
  var files = [];
  var watcher = await context.watcher.watch( a.fileProvider.path.dir( filePath ), ( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) );
    files.push( ... e.files )
    if( files.length === 1 )
    eventReady.take( e )
  })
  a.fileProvider.fileDelete( linkPath );
  await _.time.out( context.t1 );
  a.fileProvider.hardLink( linkPath, filePath2 );
  await eventReady;
  var fileNames = files.map( ( file ) => path.fullName( file.filePath ) );
  test.true( _.longHas( fileNames, 'link.js' ) )
  await watcher.close();

  /* - */

  return null;
}

//

async function hardLinkRename( test )
{
  let context = this;
  let a = test.assetFor( false );
  let path = a.fileProvider.path;

  /* - */

  test.case = 'rename'
  var filePath = a.abs( 'file.js' );
  var linkPath = a.abs( 'link.js' );
  var linkPath2 = a.abs( 'link2.js' );
  a.fileProvider.fileWrite( filePath, 'a' );
  a.fileProvider.hardLink( linkPath, filePath );
  await _.time.out( context.t1 );
  var eventReady = _.Consequence();
  var files = [];
  var watcher = await context.watcher.watch( a.fileProvider.path.dir( filePath ), ( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) );
    files.push( ... e.files );
    if( files.length > 1 )
    eventReady.take( null )
  })
  a.fileProvider.fileRename( linkPath2, linkPath );
  await eventReady;
  var fileNames = files.map( ( file ) => path.fullName( file.filePath ) );
  var exp = [ 'link.js', 'link2.js' ]
  test.contains( fileNames.sort(), exp.sort() )
  await watcher.close();

  /* - */

  return null;
}

//

async function hardLinkDelete( test )
{
  let context = this;
  let a = test.assetFor( false );
  let path = a.fileProvider.path;

  /* - */

  test.case = 'delete'
  var filePath = a.abs( 'file.js' );
  var linkPath = a.abs( 'link.js' );
  a.fileProvider.fileWrite( filePath, 'a' );
  a.fileProvider.hardLink( linkPath, filePath );
  await _.time.out( context.t1 );
  var eventReady = _.Consequence();
  var watcher = await context.watcher.watch( a.fileProvider.path.dir( filePath ), ( e ) =>
  {
    eventReady.take( e )
  })
  a.fileProvider.filesDelete( linkPath );
  var e = await eventReady;
  var exp =
  [{
    filePath : 'link.js',
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
  var watcher = await test.mustNotThrowError( () => context.watcher.watch( filePath, { onChange, enabled : 0 } ) )
  await test.mustNotThrowError( () => watcher.close() );

  /* - */

  test.case = 'enabled'
  var filePath = a.abs( 'create/dir' );
  await test.shouldThrowErrorAsync( context.watcher.watch( filePath, { onChange, enabled : 1 } ) );

  /* - */

  test.case = 'enabled later'
  var filePath = a.abs( 'create/dir' );
  var watcher = await context.watcher.watch( filePath, { onChange, enabled : 0 } );
  await test.shouldThrowErrorAsync( watcher.resume() );

  /* - */

  test.case = 'multiple paths, one is missing'
  var filePath = a.abs( 'create/dir1' );
  var filePath2 = a.abs( 'create/dir2' );
  a.fileProvider.dirMake( filePath );
  var watcher = await context.watcher.watch( [ filePath, filePath2 ], { onChange, enabled : 0 } );
  await test.shouldThrowErrorAsync( watcher.resume() );

  /* - */

  test.case = 'path created after first resume attempt'
  var filePath = a.abs( 'create/dir1' );
  a.fileProvider.filesDelete( filePath )
  var watcher = await context.watcher.watch( filePath, { onChange, enabled : 0 } );
  await test.shouldThrowErrorAsync( watcher.resume() );
  a.fileProvider.dirMake( filePath );
  await test.mustNotThrowError( () => watcher.resume() );
  await test.mustNotThrowError( () => watcher.close() );

  /* - */

  return null;

  /* - */

  function onChange(){}
}

//

async function filePathRenamed( test )
{
  let context = this;
  let a = test.assetFor( false );

  /* - */

  test.case = 'renamed before watch resumed'
  a.reflect();
  var filePath = a.abs( 'fileToRename1' );
  var filePath2 = a.abs( 'fileNewName1' );
  a.fileProvider.dirMake( filePath );
  var watcher = await context.watcher.watch( filePath, { onChange : () => {}, enabled : 0 } );
  a.fileProvider.fileRename( filePath2, filePath );
  await test.shouldThrowErrorAsync( watcher.resume() );

  /* - */

  test.case = 'renamed after watch resumed'
  a.reflect();
  var filePath = a.abs( 'fileToRename2' );
  var filePath2 = a.abs( 'fileNewName2' );
  a.fileProvider.dirMake( filePath );
  var eventReady = _.Consequence();
  await _.time.out( context.t1 );
  var files = []
  var watcher = await context.watcher.watch( filePath, ( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) )
    files.push( ... e.files )
    if( files.length === 1 )
    eventReady.take( null );
  })
  await _.time.out( context.t3 );
  a.fileProvider.fileRename( filePath2, filePath );
  await eventReady;
  test.ge( files.length, 1 );
  await watcher.close();

  /* - */

  test.case = 'renamed after watch resumed, change made'
  a.reflect();
  var filePath = a.abs( 'src' );
  var filePath2 = a.abs( 'dst' );
  a.fileProvider.dirMake( filePath );
  var eventReady = _.Consequence();
  var files = [];
  await _.time.out( context.t1 );
  var watcher = await context.watcher.watch( filePath, ( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) )
    files.push( ... e.files );
    if( files.length > 2 )
    eventReady.take( null );
  })
  a.fileProvider.fileRename( filePath2, filePath );
  test.false( a.fileProvider.fileExists( filePath ) )
  a.fileProvider.fileWrite( a.abs( 'dst/file' ), 'file' );
  await eventReady;
  var fileNames = files.map( ( file ) => _.path.name( file.filePath ) );
  test.true( _.longHas( fileNames, 'file' ) )
  await watcher.close();

  /* - */

  return null;
}

//

async function filePathMovedOutOfParent( test )
{
  let context = this;
  let a = test.assetFor( false );

  /* - */

  test.case = 'moved after watch resumed'
  a.reflect();
  var filePath = a.abs( 'parent/fileToRename' );
  var filePath2 = a.abs( 'fileNewName' );
  a.fileProvider.dirMake( filePath );
  var eventReady = _.Consequence();
  var watcher = await context.watcher.watch( filePath, ( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) )
    eventReady.take( e );
  })
  a.fileProvider.fileRename( filePath2, filePath );
  test.false( a.fileProvider.fileExists( filePath ) )
  var e = await eventReady;
  test.identical( e.files.length, 1 );
  test.identical( a.fileProvider.path.name( e.files[ 0 ].filePath ), 'fileToRename' );
  await watcher.close();

  // /* - */

  test.case = 'moved after watch resumed, change made'
  a.reflect();
  var filePath = a.abs( 'parent/fileToRename' );
  var filePath2 = a.abs( 'fileNewName' );
  a.fileProvider.dirMake( filePath );
  var eventReady = _.Consequence();
  var files = [];
  var watcher = await context.watcher.watch( filePath, ( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) )
    files.push( ... e.files );
    if( files.length > 2 )
    eventReady.take( null );
  })
  a.fileProvider.fileRename( filePath2, filePath );
  test.false( a.fileProvider.fileExists( filePath ) )
  a.fileProvider.fileWrite( a.abs( 'fileNewName/file' ), 'file' );
  await eventReady;
  test.identical( files.length, 3 );
  test.identical( a.fileProvider.path.name( files[ 0 ].filePath ), 'fileToRename' );
  test.identical( a.fileProvider.path.name( files[ 1 ].filePath ), 'file' );
  test.identical( a.fileProvider.path.name( files[ 2 ].filePath ), 'file' );
  await watcher.close();

  /* - */

  return null;
}

filePathMovedOutOfParent.experimental = 1;

//

async function filePathReaddedSame( test )
{
  let context = this;
  let a = test.assetFor( false );
  let path = a.fileProvider.path;

  /* - */

  test.case = 'renamed after watch resumed'
  a.reflect();
  var filePath = a.abs( 'fileNameOld' );
  var filePath2 = a.abs( 'fileNameNew' );
  a.fileProvider.dirMake( filePath );
  var eventReady = _.Consequence();
  var files = [];
  var watcher = await context.watcher.watch( filePath, ( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) )
    files.push( ... e.files)
    if( files.length === 1 )
    eventReady.take( null );
  })
  a.fileProvider.fileRename( filePath2, filePath );
  await _.time.out( context.t3 )
  a.fileProvider.fileRename( filePath, filePath2 );
  test.true( a.fileProvider.fileExists( filePath ) )
  await eventReady;
  test.ge( files.length, 1 );
  await watcher.close();

  /* - */

  test.case = 'renamed twice after watch resumed, change made'
  a.reflect();
  var filePath = a.abs( 'fileNameOld' );
  var filePath2 = a.abs( 'fileNameNew' );
  a.fileProvider.dirMake( filePath );
  var eventReady = _.Consequence();
  var files = [];
  var watcher = await context.watcher.watch( filePath, ( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) )
    files.push( ... e.files )
    if( _.path.name( e.files[ 0 ].filePath ) === 'file' )
    eventReady.take( null );
  })
  a.fileProvider.fileRename( filePath2, filePath );
  await _.time.out( context.t3 )
  a.fileProvider.fileRename( filePath, filePath2 );
  test.true( a.fileProvider.fileExists( filePath ) )
  a.fileProvider.fileWrite( a.abs( 'fileNameOld/file' ), 'file' );
  await eventReady;
  test.ge( files.length, 1 );
  await watcher.close();

  /* - */

  return null;
}

//

async function filePathReplacedDirByFile( test )
{
  let context = this;
  let a = test.assetFor( false );

  /* - */

  test.case = 'watched dir replaced by a terminal'
  a.reflect();
  var filePath = a.abs( 'watchDir' );
  a.fileProvider.dirMake( filePath );
  var eventReady = _.Consequence();
  var files = [];
  var watcher = await context.watcher.watch( filePath, ( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) )
    files.push( ... e.files );
    if( files.length === 2 )
    eventReady.take( e );
  })
  a.fileProvider.filesDelete( filePath );
  await _.time.out( context.t3 )
  a.fileProvider.fileWrite( filePath, 'abc' );
  test.true( a.fileProvider.fileExists( filePath ) )
  await eventReady;
  test.identical( files.length, 2 );
  await watcher.close();

  /* - */

  return null;
}

//

async function filePathReplacedFileByDir( test )
{
  let context = this;
  let a = test.assetFor( false );

  /* - */

  test.case = 'watched file replaced by a dir'
  a.reflect();
  var filePath = a.abs( 'watchFile' );
  a.fileProvider.fileWrite( filePath, 'file' );
  var eventReady = _.Consequence();
  var files = [];
  var watcher = await context.watcher.watch( filePath, ( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) )
    files.push( ... e.files );
    if( files.length === 1 )
    eventReady.take( e );
  })
  await _.time.out( context.t3 );
  a.fileProvider.fileDelete( filePath );
  a.fileProvider.dirMake( filePath );
  test.true( a.fileProvider.fileExists( filePath ) )
  await eventReady;
  test.ge( files.length, 1 );
  await watcher.close();

  /* - */

  return null;
}

//

async function filePathMultiple( test )
{
  let context = this;
  let a = test.assetFor( false );
  let path = a.fileProvider.path;

  /* - */

  test.case = 'watch multiple terminals'
  a.reflect();
  var filePath = [ a.abs( 'multipleTerminals/file1' ), a.abs( 'multipleTerminals/file2' ) ];
  a.fileProvider.fileWrite( filePath[ 0 ], 'file1' );
  a.fileProvider.fileWrite( filePath[ 1 ], 'file2' );
  var eventReady = _.Consequence();
  var files = [];
  var watcher = await context.watcher.watch( filePath, ( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) )
    files.push( ... e.files );
    if( files.length === 2 )
    eventReady.take( e );
  })
  await _.time.out( context.t1 ) //xxx: remove and investigate
  a.fileProvider.fileWrite( filePath[ 0 ], 'file11' );
  a.fileProvider.fileWrite( filePath[ 1 ], 'file22' );
  await eventReady;
  test.ge( files.length, 2 );
  await watcher.close();

  /* - */

  test.case = 'watch multiple dirs'
  a.reflect();
  var filePath = [ a.abs( 'multipleDirs/dir1' ), a.abs( 'multipleDirs/dir2' ) ];
  a.fileProvider.fileWrite( a.abs( 'multipleDirs/dir1/file1' ), 'file1' );
  a.fileProvider.fileWrite( a.abs( 'multipleDirs/dir2/file2' ), 'file2' );
  var eventReady = _.Consequence();
  var files = [];
  var watcher = await context.watcher.watch( filePath, ( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) )
    files.push( ... e.files );
    if( files.length === 2 )
    eventReady.take( e );
  })
  a.fileProvider.fileWrite( a.abs( 'multipleDirs/dir1/file1' ), 'file1' );
  a.fileProvider.fileWrite( a.abs( 'multipleDirs/dir2/file2' ), 'file2' );
  await eventReady;
  test.ge( files.length, 2 );
  await watcher.close();

  /* - */

  return null;
}

//

async function filePathIsLink( test )
{
  let context = this;
  let a = test.assetFor( false );
  let path = a.fileProvider.path;

  /* - */

  test.case = 'soft link to terminal'
  a.reflect();
  var filePathReal = a.abs( 'softToFile/file' );
  var filePath = a.abs( 'softToFile/link' );
  a.fileProvider.fileWrite( filePathReal, 'file' )
  a.fileProvider.softLink( filePath, filePathReal )
  var eventReady = _.Consequence();
  var files = [];
  var watcher = await context.watcher.watch( filePath, ( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) )
    files.push( ... e.files );
    eventReady.take( e );
  })
  await _.time.out( context.t3 ) //xxx: investigate
  a.fileProvider.fileWrite( filePath, 'a' );
  test.true( a.fileProvider.isSoftLink( filePath ) )
  await eventReady;
  test.identical( files.length, 1 );
  await watcher.close();

  /* - */

  test.case = 'soft link to dir'
  a.reflect();
  var filePathReal = a.abs( 'softToDir/dir' );
  var filePath = a.abs( 'softToDir/link' );
  a.fileProvider.dirMake( filePathReal )
  a.fileProvider.softLink( filePath, filePathReal )
  var eventReady = _.Consequence();
  var files = [];
  var watcher = await context.watcher.watch( filePath, ( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) )
    files.push( ... e.files );
    eventReady.take( e );
  })
  a.fileProvider.fileWrite( path.join( filePathReal, 'file' ), 'file' );
  test.true( a.fileProvider.isSoftLink( filePath ) )
  await eventReady;
  test.identical( files.length, 1 );
  await watcher.close();

  /* - */

  test.case = 'hard link'
  a.reflect();
  var filePathReal = a.abs( 'hardLink/file' );
  var filePath = a.abs( 'hardLink/link' );
  a.fileProvider.fileWrite( filePathReal, 'file' )
  a.fileProvider.hardLink( filePath, filePathReal )
  var eventReady = _.Consequence();
  var files = [];
  await _.time.out( context.t1 );
  var watcher = await context.watcher.watch( _.path.dir( filePath ), ( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) )
    files.push( ... e.files );
    if( files.length === 1 )
    eventReady.take( e );
  })
  await _.time.out( context.t3 * 2 ) //xxx: investigate
  a.fileProvider.fileWrite( filePathReal, 'a' );
  test.true( a.fileProvider.areHardLinked( filePath, filePathReal ) )
  await eventReady;
  test.ge( files.length, 1 );
  await watcher.close();

  /* - */

  return null;
}

//

async function filePathComplexTreeChangeNestedFile( test )
{
  let context = this;
  let a = test.assetFor( false );
  let path = a.fileProvider.path;

  var extract = new _.FileProvider.Extract
  ({
    filesTree :
    {
      'file0' : 'file0',
      'dir0' :
      {
        'file1' : 'file1',
        'dir1' :
        {
          'file2' : 'file2',
          'dir2' :
          {
            'file3' : 'file3'
          }
        }
      }
    }
  })

  /* - */

  test.case = 'change nested file'
  a.reflect();
  var filePath = a.abs( 'root' );
  a.fileProvider.dirMake( filePath )
  extract.filesReflectTo( _.fileProvider, filePath );
  var eventReady = _.Consequence();
  var files = [];
  var watcher = await context.watcher.watch( filePath, ( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) )
    files.push( ... e.files );
    eventReady.take( e );
  })
  a.fileProvider.fileWrite( path.join( filePath, 'file0' ), 'a' );
  await eventReady;
  test.identical( files.length, 1 );
  await watcher.close();

  /* - */

  return null;
}

//

async function filePathComplexTreeDeleteNestedFile( test )
{
  let context = this;
  let a = test.assetFor( false );
  let path = a.fileProvider.path;

  var extract = new _.FileProvider.Extract
  ({
    filesTree :
    {
      'file0' : 'file0',
      'dir0' :
      {
        'file1' : 'file1',
        'dir1' :
        {
          'file2' : 'file2',
          'dir2' :
          {
            'file3' : 'file3'
          }
        }
      }
    }
  })

  /* - */

  test.case = 'delete nested file'
  a.reflect();
  var filePath = a.abs( 'root' );
  a.fileProvider.dirMake( filePath )
  extract.filesReflectTo( _.fileProvider, filePath );
  var eventReady = _.Consequence();
  var files = [];
  var watcher = await context.watcher.watch( filePath, ( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) )
    files.push( ... e.files );
    eventReady.take( e );
  })
  a.fileProvider.fileDelete( path.join( filePath, 'file0' ) );
  await eventReady;
  test.identical( files.length, 1 );
  await watcher.close();

  /* - */

  return null;
}

//

async function filePathComplexTreeDeleteNestedDir( test )
{
  let context = this;
  let a = test.assetFor( false );
  let path = a.fileProvider.path;

  var extract = new _.FileProvider.Extract
  ({
    filesTree :
    {
      'file0' : 'file0',
      'dir0' :
      {
        'file1' : 'file1',
        'dir1' :
        {
          'file2' : 'file2',
          'dir2' :
          {
            'file3' : 'file3'
          }
        }
      }
    }
  })

  /* - */

  test.case = 'delete nested dir'
  a.reflect();
  var filePath = a.abs( 'root' );
  a.fileProvider.dirMake( filePath )
  extract.filesReflectTo( _.fileProvider, filePath );
  var eventReady = _.Consequence();
  var files = [];
  var watcher = await context.watcher.watch( filePath, ( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) )
    files.push( ... e.files );
    if( files.length === 1 )
    eventReady.take( null );
  })
  a.fileProvider.filesDelete( path.join( filePath, 'dir0' ) );
  await eventReady;
  test.ge( files.length, 1 );
  await watcher.close();

  /* - */

  return null;
}

//

async function filePathComplexTreeDeleteWhole( test )
{
  let context = this;
  let a = test.assetFor( false );
  let path = a.fileProvider.path;

  var extract = new _.FileProvider.Extract
  ({
    filesTree :
    {
      'file0' : 'file0',
      'dir0' :
      {
        'file1' : 'file1',
        'dir1' :
        {
          'file2' : 'file2',
          'dir2' :
          {
            'file3' : 'file3'
          }
        }
      }
    }
  })

  /* - */

  test.case = 'remove whole tree'
  a.reflect();
  var filePath = a.abs( 'root' );
  a.fileProvider.dirMake( filePath )
  extract.filesReflectTo( _.fileProvider, filePath );
  var eventReady = _.Consequence();
  var files = [];
  var expectedFilesCount = null;
  var watcher = await context.watcher.watch( filePath, ( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) )
    files.push( ... e.files );
    if( files.length === expectedFilesCount )
    eventReady.take( e );
  })
  expectedFilesCount = context.watcher.Features.recursion ? 8 : 3;
  a.fileProvider.filesDelete( filePath );
  await eventReady;
  test.identical( files.length, expectedFilesCount );
  test.false( a.fileProvider.fileExists( filePath ) );
  await watcher.close();

  /* - */

  return null;
}

//

async function watchFollowingSymlinks( test )
{
  let context = this;
  let a = test.assetFor( false );
  let path = a.fileProvider.path;

  var extract = new _.FileProvider.Extract
  ({
    filesTree :
    {
      'dir0' :
      {
        'dir1' :
        {
          'file' : 'file'
        }
      }
    }
  })

  /* - */

  test.case = 'change nested file'
  a.reflect();
  var dstPath = a.abs( 'root' );
  a.fileProvider.dirMake( dstPath )
  extract.filesReflectTo( _.fileProvider, dstPath );
  a.fileProvider.softLink( path.join( dstPath, 'link0' ), path.join( dstPath, 'dir0' ) )
  a.fileProvider.softLink( path.join( dstPath, 'dir0/link1' ), path.join( dstPath, 'dir0/dir1' ) )
  var filePathReal = path.join( dstPath, 'dir0/dir1/file' );
  var filePath = path.join( dstPath, 'link0/link1/file' );
  var eventReady = _.Consequence();
  var files = [];
  var watcher = await context.watcher.watch( filePath, ( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) )
    files.push( ... e.files );
    eventReady.take( e );
  })
  await _.time.out( context.t3 ) //xxx:investigate
  a.fileProvider.fileWrite( filePathReal, 'a' );
  await eventReady;
  test.identical( files.length, 1 );
  await watcher.close();

  /* - */

  return null;
}

//

async function renameOrder( test )
{
  let context = this;
  let a = test.assetFor( false );

  /* - */

  test.case = 'order of events after file rename'
  var filePath = a.abs( 'src' );
  var filePath2 = a.abs( 'dst' );
  a.fileProvider.fileWrite( filePath, filePath );
  await _.time.out( context.t1 );
  var eventReady = _.Consequence();
  var files = [];
  var watcher = await context.watcher.watch( a.fileProvider.path.dir( filePath ), ( e ) =>
  {
    console.log( _.entity.exportJs( e.files ) );
    files.push( ... e.files );
    if( files.length === 2 )
    eventReady.take( null )
  });
  a.fileProvider.fileRename( filePath2, filePath );
  await eventReady;
  test.identical( files.length, 2 );
  test.identical( files[ 0 ].changeType, 'delete' )
  test.identical( files[ 1 ].changeType, 'add' )
  await watcher.close();

  /* - */

  return null;
}

renameOrder.experimental = 1;

//

async function renameOrderExperiment( test )
{
  let context = this;
  let a = test.assetFor( false );

  /* - */

  var ok = true;

  while( ok )
  {
    a.reflect();
    var filePath = a.abs( 'src' );
    var filePath2 = a.abs( 'dst' );
    a.fileProvider.fileWrite( filePath, filePath );
    await _.time.out( context.t1 );
    var eventReady = _.Consequence();
    var files = [];
    var watcher = await context.watcher.watch( a.fileProvider.path.dir( filePath ), ( e ) =>
    {
      console.log( _.entity.exportJs( e.files ) );
      files.push( ... e.files );
      if( files.length === 2 )
      eventReady.take( null )
    });
    a.fileProvider.fileRename( filePath2, filePath );
    await eventReady;
    test.identical( files.length, 2 );
    ok = ok && test.identical( files[ 0 ].changeType, 'delete' )
    ok = ok && test.identical( files[ 1 ].changeType, 'add' )
    await watcher.close();
  }


  /* - */

  return null;
}

renameOrderExperiment.experimental = 1;

//

async function close( test )
{
  let context = this;
  let a = test.assetFor( false );

  /* - */

  test.case = 'no events after close'
  var filePath = a.abs( 'create/dir' );
  a.fileProvider.dirMake( a.fileProvider.path.dir( filePath ) )
  var eventReady = _.Consequence();
  var watcher = await context.watcher.watch( a.fileProvider.path.dir( filePath ),( e ) =>
  {
    eventReady.take( e )
  });
  test.true( watcher.manager.has( watcher ) );
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
  var watcher = await context.watcher.watch( a.fileProvider.path.dir( filePath ), ( e ) => {} );
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
    softLinkCreate,
    softLinkRename,
    softLinkRewrite,
    softLinkDelete,
    // hardLinkCreate, xxx: investigate mac os catalina
    hardLinkRename,
    hardLinkRewrite,
    hardLinkDelete,

    filePathIsMissing,
    filePathRenamed,
    filePathMovedOutOfParent,
    filePathReaddedSame,
    filePathReplacedDirByFile,
    filePathReplacedFileByDir,

    filePathMultiple,
    filePathIsLink,
    filePathComplexTreeChangeNestedFile,
    filePathComplexTreeDeleteNestedFile,
    filePathComplexTreeDeleteNestedDir,
    filePathComplexTreeDeleteWhole,
    watchFollowingSymlinks,

    renameOrder,
    renameOrderExperiment,

    close,
  }

}

//

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();