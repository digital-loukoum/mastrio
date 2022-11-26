let s = peg "doc":
  S              <- *Space
  jtrue          <- "true"
  jfalse         <- "false"
  jnull          <- "null"

  unicodeEscape  <- 'u' * Xdigit[4]
  escape         <- '\\' * ({ '{', '"', '|', '\\', 'b', 'f', 'n', 'r', 't' } | unicodeEscape)
  stringBody     <- ?escape * *( +( {'\x20'..'\xff'} - {'"'} - {'\\'}) * *escape)
  jstring         <- ?S * '"' * stringBody * '"' * ?S

  minus          <- '-'
  intPart        <- '0' | (Digit-'0') * *Digit
  fractPart      <- "." * +Digit
  expPart        <- ( 'e' | 'E' ) * ?( '+' | '-' ) * +Digit
  jnumber         <- ?minus * intPart * ?fractPart * ?expPart

  doc            <- JSON * !1
  JSON           <- ?S * ( jnumber | jobject | jarray | jstring | jtrue | jfalse | jnull ) * ?S
  jobject        <- '{' * ( jstring * ":" * JSON * *( "," * jstring * ":" * JSON ) | ?S ) * "}"
  jarray         <- "[" * ( JSON * *( "," * JSON ) | ?S ) * "]"
