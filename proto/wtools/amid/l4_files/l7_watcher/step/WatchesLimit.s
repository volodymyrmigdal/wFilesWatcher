#! /usr/bin/env node
( function _WatchesLimit_s_()
{
  'use strict';

  const fs = require( 'fs' );
  const cp = require( 'child_process' );

  const args = process.argv.slice( 2 );
  const command = args[ 0 ];

  if( command === 'get' )
  {
    getValue();
  }
  else if( command === 'set' )
  {
    setValue();
  }

  //

  function getValue()
  {
    if( process.platform === 'linux' )
    return getValueLinux();
    if( process.platform === 'darwin' )
    return getValueDarwin();
  }

  //

  function setValue( ... args )
  {
    if( process.platform === 'linux' )
    setValueLinux( ...args );
    if( process.platform === 'darwin' )
    setValueDarwin( ... args );
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
    let maxfiles = exec( ` sysctl kern.maxfiles` ).toString();
    maxfiles = maxfiles.split( /\s+/ )[ 1 ];
    maxfiles = Number( maxfiles );
    let maxfilesperproc = exec( ` sysctl kern.maxfilesperproc` ).toString();
    maxfilesperproc = maxfilesperproc.split( /\s+/ )[ 1 ];
    maxfilesperproc = Number( maxfilesperproc );

    console.log( `kern.maxfiles: ${maxfiles}` );
    console.log( `kern.maxfilesperproc: ${maxfilesperproc}` );

    return { current_maxfiles : maxfiles, current_maxfilesperproc : maxfilesperproc }
  }

  //

  function setValueLinux( value, permanent )
  {
    if( value === undefined )
    value = args[ 1 ];
    if( permanent === undefined )
    permanent = Boolean( args[ 2 ] );

    const defaultValue = 1048576;

    getValueLinux();

    value = Number.parseInt( value );

    if( !Number.isInteger( value ) )
    value = defaultValue;

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

  function setValueDarwin( maxfiles, maxfilesperproc, permanent )
  {
    getValueDarwin();

    if( maxfiles === undefined )
    maxfiles = args[ 1 ];
    if( maxfilesperproc === undefined )
    maxfilesperproc = args[ 2 ]
    if( permanent === undefined )
    permanent = Boolean( args[ 3 ] );

    const defaultMaxfiles = 10485760;
    const defaultMaxfilesperproc = 1048576;

    maxfiles = Number.parseInt( maxfiles );
    maxfilesperproc = Number.parseInt( maxfilesperproc );

    if( !Number.isInteger( maxfiles ) )
    maxfiles = defaultMaxfiles;

    if( !Number.isInteger( maxfilesperproc ) )
    maxfilesperproc = defaultMaxfilesperproc;

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
    cp.execSync( command, { stdio : 'inherit' } )
  }

  //

  module.exports =
  {
    setValue,
    getValue
  }

})()