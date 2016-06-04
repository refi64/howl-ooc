howl.mode.register
  name: 'ooc'
  extensions: {'ooc'}
  aliases: {'rock'}
  create: -> bundle_load 'mode'
  parent: 'curly_mode'

unload = -> howl.mode.unregister 'ooc'

{
  info:
    author: 'Ryan Gonzalez'
    description: 'An ooc bundle'
    license: 'MIT'
  :unload
}
