
string = between("\"", "\"", "\\")
number = createNumberExpression()
boolean = "true" | "false"

String := string[.value]
Number := number[.value]
Boolean := boolean[.value]
Null := "null"[.value]
Undefined := "undefined"[.value]

Object := "{" list(string[>>properties.key] ":" expression[>>properties.value]) "}"
Array := "[" list(expression[>>items]) "]"

expression = String | Number | Boolean | Null | Undefined | Object | Array
