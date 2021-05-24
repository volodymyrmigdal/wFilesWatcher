( function _Top_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( './Basic.s' );

  require( '../l1/Namespace.s' );
  require( '../l2/WatcherManager.s' );
  require( '../l3/Watcher.s' );
  require( '../l4/Fb.ss' );
  require( '../l4/Fs.ss' );

  module[ 'exports' ] = _;
}

})();
