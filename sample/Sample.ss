var _ = require( '..' )
var path = require( 'path' )

var o2 = _.files.watcher.default.watch({ [ __filename ] : null })

o2.on( 'change', ( got ) =>
{
  console.log( got )
})

o2.resume()
// o2.close()
