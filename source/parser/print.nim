import strutils
import system/io
import std/terminal
import std/sequtils
import std/options

import ./nodes

type
  Property = object
    name*: string
    node*: Node

proc recursivePrint(node: Node, level = 0): void

proc print*(node: Node) =
  recursivePrint(node)
  stdout.write "\n"

proc printNewLine(level: int) =
  stdout.styledWrite("\n", styleDim, "•  ".repeat(level))

proc printKind(node: Node) =
  stdout.styledWrite(styleBright, fgMagenta, styleItalic, $node.kind)

proc printSubType(subtype: string) =
  stdout.styledWrite(" ", styleBright, fgGreen, subtype)

proc printProperties(properties: seq[Property], level: int) =
  for index, property in properties:
    printNewLine(level)
    if index == properties.len - 1:
      stdout.styledWrite("└─ ")
    else:
      stdout.styledWrite("├─ ")
    stdout.styledWrite(styleDim, styleUnderscore, property.name)
    stdout.styledWrite(": ")
    recursivePrint(property.node, level + 1)

proc printChildren(children: seq[Node], level: int) =
  for index, child in children:
    printNewLine(level)
    if index == children.len - 1:
      stdout.styledWrite("└─ ")
    else:
      stdout.styledWrite("├─ ")
    recursivePrint(child, level + 1)

proc recursivePrint(node: Node, level = 0) =
  if node == nil:
    stdout.styledWrite(styleItalic, styleDim, "nil")
    return

  case node.kind
    of NodeKind.Identifier:
      stdout.styledWrite(styleUnderscore, fgCyan, node.name)
    of NodeKind.SimpleToken:
      stdout.styledWrite(fgGreen, '"' & node.simpleExpression & '"')
    of NodeKind.Set:
      printKind(node)
      printChildren(node.setItems, level)
    of NodeKind.Repeat:
      printKind(node)
      stdout.styledWrite(" (", $(node.minimum), ", ", (if node.maximum.isSome(): $(node.maximum.get()) else: "..."), ")")
      printChildren(@[node.repeatExpression], level)
    of NodeKind.Call:
      printKind(node)
      stdout.styledWrite(" ", node.functionName, "()")
      printChildren(node.parameters, level)
    of NodeKind.Capture:
      printKind(node)
      stdout.styledWrite(" ", node.captureType)
      for index in 0 ..< node.capturePath.len:
        if index > 0: stdout.styledWrite(".")
        stdout.styledWrite(node.capturePath[index])
      printChildren(@[node.captureExpression], level)
