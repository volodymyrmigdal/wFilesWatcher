#! /usr/bin/env node
( function _WatchesLimit_s_()
{
  'use strict';

  const fs = require( 'fs' );
  const cp = require( 'child_process' );

  const args = process.argv.slice( 2 );
  const command = args[ 0 ];
  const permanent = args[ 1 ];

  if( command === 'get' )
  getValue();
  else if( command === 'set' )
  setValue( permanent );

  //

  function getValue()
  {
    if( process.platform === 'linux' )
    return getValueLinux();
    if( process.platform === 'darwin' )
    return getValueDarwin();
  }

  //

  function setValue( permanent )
  {
    if( permanent === undefined )
    permanent = true;
    permanent = !!permanent;

    if( process.platform === 'linux' )
    setValueLinux( permanent );
    if( process.platform === 'darwin' )
    setValueDarwin( permanent );
  }

  //

  function getValueLinux()
  {
    let currentValue = fs.readFileSync( `/proc/sys/fs/inotify/max_user_watches` );
    console.log( `Current max_user_watches: ${currentValue}` );
    return Number( currentValue );
  }

  //

  function getValueDarwin()
  {
    let maxfiles = execCollectingOutput( ` sysctl kern.maxfiles` ).toString();
    maxfiles = maxfiles.split( /\s+/ )[ 1 ];
    maxfiles = Number( maxfiles );
    let maxfilesperproc = execCollectingOutput( ` sysctl kern.maxfilesperproc` ).toString();
    maxfilesperproc = maxfilesperproc.split( /\s+/ )[ 1 ];
    maxfilesperproc = Number( maxfilesperproc );

    console.log( `kern.maxfiles: ${maxfiles}` );
    console.log( `kern.maxfilesperproc: ${maxfilesperproc}` );

    return { current_maxfiles : maxfiles, current_maxfilesperproc : maxfilesperproc }
  }

  //

  function setValueLinux( permanent )
  {
    let current = getValueLinux();

    let value = 1048576;

    if( current >= value )
    return;

    console.log( `Changing max_user_watches to ${value}` );

    if( permanent )
    {
      exec( `sudo sh -c "echo fs.inotify.max_user_watches=${value} >> /etc/sysctl.conf"` )
      console.warn( 'The new value is permanent.' );
      console.warn( 'To disable it edit "fs.inotify.max_user_watches" line in your /etc/sysctl.conf file' );
    }
    else
    {
      exec( `sudo sysctl fs.inotify.max_user_watches=${value}`)
      console.warn( 'The new value will persist until next reboot.' )
    }

    console.log( 'Reloading config file to avoid reboot' );
    exec( `sudo sysctl -p` );

    getValueLinux();
  }

  //

  function setValueDarwin( permanent )
  {
    var current = getValueDarwin();

    let maxfiles = 10485760;
    let maxfilesperproc = 10485760;

    if( current.current_maxfiles >= maxfiles && current.current_maxfilesperproc >= maxfilesperproc )
    return;

    console.log( `Changing maxfiles to ${maxfiles}` );
    console.log( `Changing maxfilesperproc to ${maxfilesperproc}` );

    if( permanent )
    {
      exec( `sudo sh -c "echo kern.maxfiles=${maxfiles} >> /etc/sysctl.conf"` )
      exec( `sudo sh -c "echo kern.maxfilesperproc=${maxfilesperproc} >> /etc/sysctl.conf"` )
      console.warn( 'The new values are permanent.' );
      console.warn( 'To disable it edit lines "kern.maxfiles" and "kern.maxfilesperproc" in your /etc/sysctl.conf file' );
    }
    else
    {
      exec( `sudo sysctl -w kern.maxfiles=${maxfiles}` )
      exec( `sudo sysctl -w kern.maxfilesperproc=${maxfilesperproc}` )
      console.warn( 'The new values will persist until next reboot.' )
    }

    getValueDarwin();
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

  module.exports =
  {
    setValue,
    getValue
  }

})()