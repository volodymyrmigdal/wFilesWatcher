( function _WatchersLimit_test_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( 'Tools' );

  _.include( 'wTesting' );;
  _.include( 'wProcess' );
  _.include( 'wFiles' );

  require( '../l4_files/l7_watcher/include/Top.s' );
  var WatchesLimit = require( '../l4_files/l7_watcher/step/WatchesLimit.s' );
}

const _global = _global_;
const _ = _global_.wTools;

// --
// context
// --

function onSuiteBegin()
{
  let self = this;

  self.suiteTempPath = _.path.tempOpen( _.path.join( __dirname, '../..'  ), 'WatchesLimit' );
  self.assetsOriginalPath = _.path.join( __dirname, '_asset' );
}

//

function onSuiteEnd()
{
  let self = this;
  _.assert( _.strHas( self.suiteTempPath, '/WatchesLimit-' ) )
  _.path.tempClose( self.suiteTempPath );
}

//

async function watchesLimitThrowing( test )
{
  let context = this;
  let a = test.assetFor( false );
  let rootDir = a.abs( 'root' );

  /* - */

  if( !_.process.insideTestContainer() || process.platform != 'linux' )
  {
    test.true( true );
    return;
  }

  if( process.platform === 'linux' )
  {
    var value = WatchesLimit.getValue();
    generateFiles( value );
    var watcher = _.files.watcher.fs.watch( rootDir, { enabled : 0 } );
    await test.shouldThrowErrorAsync( watcher.resume() );
    WatchesLimit.setValue( false );
    await test.mustNotThrowError( () => watcher.resume() );
    await watcher.close();
  }

  /* - */

  return null;

  function generateFiles( nfiles )
  {
    for( let i = 0; i < nfiles; i++ )
    {
      let filePath = a.fileProvider.path.join( rootDir, i.toString() );
      a.fileProvider.fileWrite( filePath, filePath )
    }
  }
}

watchesLimitThrowing.timeOut = 120000;
watchesLimitThrowing.rapidity = -2;

// --
// declare
// --

const Proto =
{

  name : 'WatchesLimit',
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
    watchesLimitThrowing
  }

}

//

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();