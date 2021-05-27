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
  /* - */

  if( !_.process.insideTestContainer() || process.platform === 'win32' )
  {
    test.true( true );
    return;
  }

  if( process.platform === 'linux' )
  {
    var beforeValue = WatchesLimit.getValue();
    test.gt( beforeValue, 0 );
    WatchesLimit.setValue( 0 );
    var watcher = _.files.watcher.fs.watch( __dirname, { enabled : 0 } );
    await test.shouldThrowErrorAsync( watcher.resume() );
    WatchesLimit.setValue( beforeValue );
    var value = WatchesLimit.getValue();
    test.identical( value, beforeValue );
    await test.mustNotThrowError( () => watcher.resume() );
    await watcher.close();
  }
  else if( process.platform === 'darwin' )
  {
    var beforeValue = WatchesLimit.getValue();
    test.gt( beforeValue.current_maxfiles, 0 );
    test.gt( beforeValue.current_maxfilesperproc, 0 );
    WatchesLimit.setValue( 0, 0 );
    var watcher = _.files.watcher.fs.watch( __dirname, { enabled : 0 } );
    await test.shouldThrowErrorAsync( watcher.resume() );
    WatchesLimit.setValue( current_maxfiles, current_maxfilesperproc );
    var value = WatchesLimit.getValue();
    test.identical( value.current_maxfiles, beforeValue.current_maxfiles );
    test.identical( value.current_maxfilesperproc, beforeValue.current_maxfilesperproc );
    await test.mustNotThrowError( () => watcher.resume() );
    await watcher.close();
  }

  /* - */

  return null;
}

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