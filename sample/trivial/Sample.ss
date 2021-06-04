
var _ = require( 'wfileswatcher' )

let ready = _.files.watcher.fs.watch( __filename, ( e ) =>
{
  console.log( e.files )
});

let fsWatcher = null;

ready.then( ( watcher ) =>
{
  fsWatcher = watcher;
  console.log( `Make some change in ${__filename}` )
  return null;
})

ready.delay( 5000 )

ready.then( () => fsWatcher.close() )
