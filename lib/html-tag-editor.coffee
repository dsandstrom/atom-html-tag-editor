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

        openTagRegex  = /\w+/
        closeTagRegex = /<\/[\w\s]+>/

        # opening tag
        tagRange =
          cursor.getCurrentWordBufferRange({wordRegex: openTagRegex})
        tagText  = editor.getTextInBufferRange(tagRange)
        tagText = /\w+/.exec(tagText)
        return unless tagText
        tagText = tagText[0]
        console.log tagText
        closingTag = "</#{tagText}"
        closingRegExp = new RegExp(closingTag, 'g')
        closingTagRange = [tagRange.end, [editor.getLastBufferRow(), 0]]
        # console.log closingTagRange
        # closingTagText = editor.getTextInBufferRange(closingTagRange)
        # console.log closingTagText
        editor.scanInBufferRange closingRegExp, closingTagRange, (obj) ->
          console.log obj

      editor.onDidDestroy ->
        editorSubscriptions.dispose()

  deactivate: ->
    @subscriptions.dispose()
