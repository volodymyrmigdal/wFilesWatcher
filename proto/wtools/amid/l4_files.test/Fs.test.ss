( function _FsWatcher_test_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( 'Tools' );

  _.include( 'wTesting' );;
  _.include( 'wProcess' );
  _.include( 'wFiles' );

  require( './aWatcher.test.ss' );

}

const _ = _global_.wTools;
const Parent = wTests[ 'Tools.files.watcher.abstract' ];
_.assert( !!Parent );

// --
// context
// --

function onSuiteBegin()
{
  let self = this;

  self.suiteTempPath = _.path.tempOpen( _.path.join( __dirname, '../..'  ), 'FsWatcher' );
  self.assetsOriginalPath = _.path.join( __dirname, '_asset' );
}

// --
// declare
// --

const Proto =
{

  name : 'Tools.files.watcher.fs',
  silencing : 1,

  onSuiteBegin,
  routineTimeOut : 60000,

  context :
  {
    watcher : _.files.watcher.fs
  },

  tests :
  {
  }

}

//

const Self = wTestSuite( Proto ).inherit( Parent );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();