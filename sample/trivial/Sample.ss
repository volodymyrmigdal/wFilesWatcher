
var _ = require( '..' )

let ready = _.files.watcher.fs.watch({ [ __filename ] : null });
let fsWatcher = null;

ready.then( ( watcher ) =>
{
  fsWatcher = watcher;

  console.log( `Make some change in ${__filename}` )

  watcher.on( 'change', ( e ) =>
  {
    console.log( e.files )
  })

  return null;
})

ready.delay( 5000 )

ready.then( () => fsWatcher.close() )
