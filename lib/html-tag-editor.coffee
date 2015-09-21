{CompositeDisposable} = require 'atom'

module.exports = HtmlTagEditor =
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.workspace.observeTextEditors (editor) ->
      editorSubscriptions = new CompositeDisposable
      editorScopeDescriptor = editor.getRootScopeDescriptor()
      editorScope = editorScopeDescriptor.getScopesArray()
      return unless editorScope and editorScope.length

      if editorScope[0].match(/text\.html/)
        console.log 'editor is html'
      else
        console.log 'editor is not html'
        return

      editorSubscriptions.add editor.onDidChangeCursorPosition (event) ->
        cursor = event.cursor
        return unless cursor
        scopeDescriptor = cursor.getScopeDescriptor()
        return unless scopeDescriptor

        scopes = scopeDescriptor.getScopesArray()
        return unless scopes and scopes.length > 1
        scope = scopes[1]

        return unless scope.match(/meta\.tag/)

        tagRange = cursor.getCurrentWordBufferRange()
        tagText = editor.getTextInBufferRange(tagRange)
        tagText = tagText.replace(/(<\/?|>)/, '')
        return unless tagText
        console.log tagText

      editor.onDidDestroy ->
        editorSubscriptions.dispose()

  deactivate: ->
    @subscriptions.dispose()
