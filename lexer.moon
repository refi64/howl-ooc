howl.aux.lpeg_lexer ->
  c = capture
  ident = (alpha + '_')^1 * (alpha + digit + '_')^0
  ws = blank^0

  identifier = c 'identifier', ident

  keyword = c 'keyword', word {
    'import', 'include', 'use', 'class', 'cover', 'extends', 'from', 'func',
    'implements', 'interface', 'operator', 'extend', 'enum', 'get', 'set',
    'abstract', 'static', 'final', 'extern', 'const', 'proto', 'unmangled',
    'inline', 'private', 'protected', 'public', 'internal', 'new', 'as', 'break',
    'return', 'continue', 'case', 'if', 'else', 'match', 'while', 'for', 'try',
    'catch', 'in'
  }

  type = c 'type', any {
    upper * ident
    word {
      'Int8', 'Int16', 'Int32', 'Int64', 'Int80', 'Int128', 'Int',
      'UInt8', 'UInt16', 'UInt32', 'UInt64', 'UInt80', 'UInt128', 'UInt',
      'Octet', 'Short', 'UShort', 'Long', 'ULong', 'LLong', 'ULLong',
      'Double', 'LDouble', 'Float32', 'Float64', 'Float128', 'Float',
      'Char', 'UChar', 'SChar', 'WChar', 'String', 'CString',
      'Void', 'Pointer', 'Bool', 'SizeT', 'This', 'Class', 'Object', 'Func'
    }
  }

  special = c 'special', word { 'this', 'super', 'true', 'false', 'null' }

  constant = c 'constant', upper^1 * -#ident

  class_def = sequence {
    c 'type_def', ident
    ws
    c 'operator', ':'
    ws
    c 'keyword', word { 'class', 'enum', 'cover', 'interface' }
  }

  fdecl = sequence {
    c 'fdecl', ident
    ws
    c 'operator', ':'
    ws
    any({
      sequence {
        c 'keyword', word { 'extern' }
        ws
        any({
          sequence {
            c 'operator', '('
            ws
            identifier
            ws
            c 'operator', ')'
          }
          c 'keyword', word { 'proto' }
        })^-1
        ws
      }
      sequence {
        c 'keyword', word { 'static', 'final' }
        ws
      }
    })^-1
    c 'keyword', word { 'func' }
  }

  char = span "'", "'", '\\'
  number = c 'number', any {
    float
    P'0b' * S'01'^1
    P'0c' * R'07'^1
    hexadecimal
    char
    sequence {
      digit
      (digit + '_')^0
      (S'eE' * S'+-'^-1 * digit * (digit + '_')^0)^-1
    }
  }

  operator = c 'operator', S':;,=()[]{}.!+-*/&|~<>@?'

  comment = c 'comment', any {
    span '//', eol
    span '/*', '*/'
  }

  P {
    'all'

    all: any {
      V'string'
      number
      comment
      class_def
      constant
      fdecl
      keyword
      type
      special
      identifier
      operator
    }

    string: c('string', '"') * V'string_chunk'
    string_chunk: sequence {
      c 'string', scan_to P'"' + #P'#{', '\\'
      V'string_interpolation'^0
    }
    string_interpolation: sequence {
      c 'operator', '#{'
      (-P'}' * (V'all' + 1))^1
      c 'operator', '}'
      V'string_chunk'
    }
  }
