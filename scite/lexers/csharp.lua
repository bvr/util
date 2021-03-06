-- Copyright 2006-2011 Mitchell mitchell<att>caladbolg.net. See LICENSE.
-- C# LPeg lexer.

local l = lexer
local token, style, color, word_match = l.token, l.style, l.color, l.word_match
local P, R, S = l.lpeg.P, l.lpeg.R, l.lpeg.S

module(...)

-- Whitespace.
local ws = token(l.WHITESPACE, l.space^1)

-- Comments.
local line_comment = '//' * l.nonnewline_esc^0
local block_comment = '/*' * (l.any - '*/')^0 * P('*/')^-1
local comment = token(l.COMMENT, line_comment + block_comment)

-- Strings.
local sq_str = l.delimited_range("'", '\\', true, false, '\n')
local dq_str = l.delimited_range('"', '\\', true, false, '\n')
local ml_str = P('@')^-1 * l.delimited_range('"', nil, true)
local string = token(l.STRING, sq_str + dq_str + ml_str)

-- Numbers.
local number = token(l.NUMBER, (l.float + l.integer) * S('lLdDfFMm')^-1)

-- Preprocessor.
local preproc_word = word_match {
  'define', 'elif', 'else', 'endif', 'error', 'if', 'line', 'undef', 'warning',
  'region', 'endregion'
}
local preproc = token(l.PREPROCESSOR,
                      #P('#') * l.starts_line('#' * S('\t ')^0 * preproc_word *
                      (l.nonnewline_esc^1 + l.space * l.nonnewline_esc^0)))

-- Keywords.
local keyword = token(l.KEYWORD, word_match {
  'class', 'delegate', 'enum', 'event', 'interface', 'namespace', 'struct',
  'using', 'abstract', 'const', 'explicit', 'extern', 'fixed', 'implicit',
  'internal', 'lock', 'out', 'override', 'params', 'partial', 'private',
  'protected', 'public', 'ref', 'sealed', 'static', 'readonly', 'unsafe',
  'virtual', 'volatile', 'add', 'as', 'assembly', 'base', 'break', 'case',
  'catch', 'checked', 'continue', 'default', 'do', 'else', 'finally', 'for',
  'foreach', 'get', 'goto', 'if', 'in', 'is', 'new', 'remove', 'return', 'set',
  'sizeof', 'stackalloc', 'super', 'switch', 'this', 'throw', 'try', 'typeof',
  'unchecked', 'value', 'void', 'while', 'yield',
  'null', 'true', 'false'
})

-- Types.
local type = token(l.TYPE, word_match {
  'bool', 'byte', 'char', 'decimal', 'double', 'float', 'int', 'long', 'object',
  'operator', 'sbyte', 'short', 'string', 'uint', 'ulong', 'ushort'
})

-- Identifiers.
local identifier = token(l.IDENTIFIER, l.word)

-- Operators.
local operator = token(l.OPERATOR, S('~!.,:;+-*/<>=\\^|&%?()[]{}'))

_rules = {
  { 'whitespace', ws },
  { 'keyword', keyword },
  { 'type', type },
  { 'identifier', identifier },
  { 'string', string },
  { 'comment', comment },
  { 'number', number },
  { 'preproc', preproc },
  { 'operator', operator },
  { 'any_char', l.any_char },
}

_foldsymbols = {
  _patterns = { '%l+', '[{}]', '/%*', '%*/', '//' },
  [l.PREPROCESSOR] = {
    region = 1, endregion = -1,
    ['if'] = 1, ifdef = 1, ifndef = 1, endif = -1
  },
  [l.OPERATOR] = { ['{'] = 1, ['}'] = -1 },
  [l.COMMENT] = { ['/*'] = 1, ['*/'] = -1, ['//'] = l.fold_line_comments('//') }
}
