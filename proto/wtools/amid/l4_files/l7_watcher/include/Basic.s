( function _Basic_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( 'Tools' );

  _.include( 'wProto' );
  _.include( 'wPathBasic' );
  _.include( 'wPathTools' );
  _.include( 'wConsequence' );
  _.include( 'wEventHandler' );

  module[ 'exports' ] = _;
}

})();
