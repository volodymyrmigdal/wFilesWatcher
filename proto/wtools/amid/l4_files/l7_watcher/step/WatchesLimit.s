#! /usr/bin/env node
( function _WatchesLimit_s_()
{
  'use strict';

  const fs = require( 'fs' );
  const cp = require( 'child_process' );

  const DRY = false;

  //

  function getLimitLinux()
  {
    let currentValue = fs.readFileSync( `/proc/sys/fs/inotify/max_user_watches` );
    return Number( currentValue );
  }

  //

  function getLimitDarwin()
  {
    let maxfiles = execCollectingOutput( `sysctl kern.maxfiles` ).toString();
    maxfiles = maxfiles.split( /\s+/ )[ 1 ];
    maxfiles = Number( maxfiles );

    let maxfilesperproc = execCollectingOutput( `sysctl kern.maxfilesperproc` ).toString();
    maxfilesperproc = maxfilesperproc.split( /\s+/ )[ 1 ];
    maxfilesperproc = Number( maxfilesperproc );

    return { maxfiles, maxfilesperproc }
  }

  //

  function increaseLimit( permanent )
  {
    if( permanent === undefined )
    permanent = true;
    else
    permanent = boolFrom( permanent );

    if( process.platform === 'linux' )
    increaseLimitLinux( permanent );
    else if( process.platform === 'darwin' )
    increaseLimitDarwin( permanent );
  }

  //

  function increaseLimitLinux( permanent )
  {
    const value = 1048576;

    const currentLimit = getLimitLinux();

    if( currentLimit >= value )
    return;

    console.log( `Changing max_user_watches to ${value}` );

    if( !DRY )
    exec( `sudo sysctl fs.inotify.max_user_watches=${value}`)

    if( permanent )
    {
      if( !DRY )
      exec( `sudo sh -c "echo fs.inotify.max_user_watches=${value} >> /etc/sysctl.conf"` )
      console.warn( 'The new value is permanent.' );
      console.warn( 'To disable it edit "fs.inotify.max_user_watches" line in your /etc/sysctl.conf file' );
    }
    else
    {
      console.warn( 'The new value will persist until next reboot.' )
    }

    console.log( 'Reloading config file to avoid reboot' );

    if( !DRY )
    exec( `sudo sysctl -p` );
  }

  //

  function increaseLimitDarwin( permanent )
  {
    const maxfiles = 10485760;
    const maxfilesperproc = 1048576;

    const currentLimit = getLimitDarwin();
    let changed = 0;

    if( currentLimit.maxfiles < maxfiles )
    {
      console.log( `Changing maxfiles to ${maxfiles}` );
      changed = 1;

      if( !DRY )
      {
        exec( `sudo sysctl -w kern.maxfiles=${maxfiles}` )
        if( permanent )
        exec( `sudo sh -c "echo kern.maxfiles=${maxfiles} >> /etc/sysctl.conf"` )
      }
    }

    if( currentLimit.maxfilesperproc < maxfilesperproc )
    {
      console.log( `Changing maxfilesperproc to ${maxfilesperproc}` );
      changed = 1;
      if( !DRY )
      {
        exec( `sudo sysctl -w kern.maxfilesperproc=${maxfilesperproc}` )
        if( permanent )
        exec( `sudo sh -c "echo kern.maxfilesperproc=${maxfilesperproc} >> /etc/sysctl.conf"` )
      }
    }

    if( !changed )
    return;

    if( permanent )
    {
      console.warn( 'The new values are permanent.' );
      console.warn( 'To disable it edit lines "kern.maxfiles", "kern.maxfilesperproc" in your /etc/sysctl.conf file' );
    }
    else
    {
      console.warn( 'The new values will persist until next reboot.' )
    }
  }

  //

  function exec( command )
  {
    return cp.execSync( command, { stdio : 'inherit' } )
  }

  //

  function execCollectingOutput( command )
  {
    return cp.execSync( command )
  }

  //

  function boolFrom( src )
  {
    if( src === true || src === false )
    return src;

    src = src.toLowerCase();
    if( src === '0' )
    return false;
    if( src === 'false' )
    return false;
    if( src === '1' )
    return true;
    if( src === 'true' )
    return true;
    return src;
  }

  //

  if( typeof module !== 'undefined' && !module.parent )
  {
    increaseLimit( process.argv[ 2 ] );
  }

  //

  module.exports =
  {
    increaseLimit,
    getLimitLinux,
    getLimitDarwin
  }

})()