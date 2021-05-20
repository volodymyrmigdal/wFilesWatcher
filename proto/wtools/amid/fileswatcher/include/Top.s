( function _Top_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( './Basic.s' );

  require( '../l1/Namespace.s' );
  require( '../l2/Fb.ss' );
  require( '../l2/Fs.ss' );

  module[ 'exports' ] = _;
}

})();
