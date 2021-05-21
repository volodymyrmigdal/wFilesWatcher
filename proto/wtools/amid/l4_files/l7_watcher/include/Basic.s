( function _Basic_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( '../../../../../node_modules/Tools' );

  _.include( 'wProto' );
  _.include( 'wPathBasic' );
  _.include( 'wPathTools' );
  _.include( 'wConsequence' );

  module[ 'exports' ] = _;
}

})();
