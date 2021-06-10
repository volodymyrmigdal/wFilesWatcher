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

  if( !_.process.insideTestContainer() )
  {
    test.true( true );
    return;
  }

  var a = test.assetFor( false );
  a.shell.predefined.sync = 1;
  a.reflect();

  if( process.platform === 'linux' )
  {
    a.shell( `sudo sysctl fs.inotify.max_user_watches=0` )
    var watcher = _.files.watcher.fs.watch( __dirname, { enabled : 0, onChange : () => {} } );
    await test.shouldThrowErrorAsync( watcher.resume() );
    WatchesLimit.increaseLimit( false );
    await test.mustNotThrowError( () => watcher.resume() );
    await watcher.close();
  }
  else if( process.platform === 'darwin' )
  {
    var currentLimit = WatchesLimit.getLimitDarwin();
    console.log( currentLimit )
    if( currentLimit.maxfiles > 1000 )
    {
      test.true( true );
    }
    else
    {
      await createFiles( 1000 );
      var watcher = _.files.watcher.fs.watch( a.abs( '.' ), { enabled : 0, onChange : () => {} } );
      await test.shouldThrowErrorAsync( watcher.resume() );
      WatchesLimit.increaseLimit( false );
      await test.mustNotThrowError( () => watcher.resume() );
      await watcher.close();
    }
  }
  else
  {
    test.true( true );
  }

  /* - */

  return null;

  /* - */

  function createFiles( number )
  {
    let cons = [];
    for( let i = 0; i < number; i++ )
    {
      let con = a.fileProvider.fileWrite({ filePath: a.abs( `file${i}` ), data : i.toString(), sync : 0 })
      cons.push( con )
    }
    return _.Consequence.AndKeep( ... cons );
  }
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