var _ = require( '..' )


var o2 = _.files.watcher.fb.watch( __dirname )
o2.enable()
.thenGive( () =>
{
  console.log( 'Make some change in', __dirname )
})