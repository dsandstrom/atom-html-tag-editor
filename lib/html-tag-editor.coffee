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

      return unless editorScope[0].match(/text\.html/)

      editorSubscriptions.add editor.onDidChangeCursorPosition (event) ->
        cursor = event.cursor
        return unless cursor
        scopeDescriptor = cursor.getScopeDescriptor()
        return unless scopeDescriptor

        scopes = scopeDescriptor.getScopesArray()
        return unless scopes and scopes.length > 1
        scope = scopes[1]

        return unless scope.match(/meta\.tag/)

        startTagRegex = /[<\s]/
        endTagRegex = /[>\s]/
        startOfTag =
          cursor.getBeginningOfCurrentWordBufferPosition(
            {wordRegex: startTagRegex}
          )
        endOfTag =
          cursor.getEndOfCurrentWordBufferPosition({wordRegex: endTagRegex})
        tagRange = [startOfTag, endOfTag]
        console.log tagRange
        tagText = editor.getTextInBufferRange(tagRange)
        return unless tagText

        tagText = tagText.trim()
        console.log tagText

      editor.onDidDestroy ->
        editorSubscriptions.dispose()

  deactivate: ->
    @subscriptions.dispose()
