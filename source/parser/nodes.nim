import std/options

type NodeKind* = enum
  SimpleToken
  Set
  Repeat
  Call
  Identifier
  Capture
  
  # NodeDeclaration
  # ExpressionDeclaration
  # FunctionDeclaration


type Node* = ref object
  start*: int
  length*: int

  case kind*: NodeKind
    of SimpleToken:
      simpleExpression*: string
    of Identifier:
      name*: string
    of Set:
      setItems*: seq[Node]
    of Call:
      functionName*: string
      parameters*: seq[Node]
    of Repeat:
      repeatExpression*: Node
      minimum*: int
      maximum*: Option[int]
    of Capture:
      captureType*: string
      capturePath*: seq[string]
      captureExpression*: Node
