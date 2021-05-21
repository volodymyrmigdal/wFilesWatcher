var _ = require( '..' )

var o2 = _.files.watcher.default.watch( __dirname )

o2.on( 'change', ( got ) =>
{
  console.log( got )
})

o2.enable()
