import npeg

import ./nodes
import ./print

type ParserInstance* = ref object
  nodes*: seq[Node]

let mastrioParser* = peg(Statement, parser: ParserInstance):
  BETWEEN(start, stop) <- start * >*(1 - stop) * stop
  LIST(expression) <- CUSTOM_LIST(expression, ',')
  CUSTOM_LIST(expression, separator) <- _ * ?>expression * *(_ * separator * _ * >expression) * _
  _ <- *Blank
  END_OF_LINE <- _ * ('\n' | !1)

  Identifier <- >+Alpha:
    parser.nodes.add(Node(kind: NodeKind.Identifier, name: $1))
 
  SimpleToken <- BETWEEN('"', '"'):
    parser.nodes.add(Node(kind: NodeKind.SimpleToken, simpleExpression: $1))
  
  Set <- '{' * LIST(Expression) * '}':
    # parser.nodes.add(Node(kind: NodeKind.Set, complexExpression: $1))
    var setItems = newSeq[Node](capture.len - 1)
    for i in 1 ..< capture.len:
      setItems[^i] = parser.nodes.pop()
    parser.nodes.add(Node(kind: NodeKind.Set, setItems: setItems))

  OneOrMore <- '+' * Expression:
    parser.nodes.add(Node(kind: NodeKind.Repeat, minimum: 1, repeatExpression: parser.nodes.pop()))

  ZeroOrMore <- '*' * Expression:
    parser.nodes.add(Node(kind: NodeKind.Repeat, repeatExpression: parser.nodes.pop()))

  Group <- ('(' * Expression * ')') ^ 0

  Capture <- '[' * _ * >('.' | ">>") * _ * CUSTOM_LIST(Identifier, '.') * Expression * ']':
    var path = newSeq[Node](capture.len - 2)
    let captureExpression = parser.nodes.pop()
    for i in 1 ..< capture.len - 1:
      path[^i] = parser.nodes.pop()
    parser.nodes.add(Node(
      kind: NodeKind.Call,
      captureType: $1,
      capturePath: path,
      captureExpression: captureExpression
    ))

  Call <- >+Alpha * _ * '(' * LIST(Expression) * ')':
    var parameters = newSeq[Node](capture.len - 2)
    for i in 1 ..< capture.len - 1:
      parameters[^i] = parser.nodes.pop()
    parser.nodes.add(Node(
      kind: NodeKind.Call,
      functionName: $1,
      parameters: parameters
    ))

  
  
  Expression <- _ * RawExpression * _
  RawExpression <- Call | Set | OneOrMore | ZeroOrMore | SimpleToken | Identifier
  Expressions <- _ * RawExpression * *(+Blank * RawExpression) * _

  Statement <- Expressions * END_OF_LINE

proc parseMastrio*(input: string): ParserInstance =
  result = ParserInstance()
  let match = mastrioParser.match(input, result)
  if match.ok == false:
    echo "🤕 Error while parsing line"
  else:
    for node in result.nodes:
      node.print()
