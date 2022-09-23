module kut.parser;

import std.stdio;
import std.algorithm.searching;
import std.conv;
import std.typecons;
import std.utf;
import std.uni;
import std.string;
import std.sumtype;
import std.meta : Alias;
import std.range.primitives : popBack;

size_t[2] matching(const dstring self, const dchar startChar = '(', const dchar endChar = ')')
   //in(self.balancedParens(startChar, endChar) == true, "The string must have balanced parantheses to be parsed")
   out(r; r[0] >= 0 && r[0] < self.length, "Start index must be inside the string")
   out(r; r[1] >= 0 && r[1] < self.length, "End index must be inside the string")
   out(r; r[0] <= r[1], "Equal range means no matching pair is found, otherwise, start must be before the end")
{
   size_t start = 0, end = 0;
   size_t depth = 0;
   bool hasStartFound = false;
   for(size_t i = 0; i < self.length; i++) {
      if(self[i] == startChar) {
         depth += 1;
         if(!hasStartFound) {
            start = i+1;
            hasStartFound = true;
         }
      } else if(self[i] == endChar) {
         depth -= 1;
         if(depth == 0) {
            end = i;
         }
      }
      if(hasStartFound && depth == 0) {
         return [start, end];
      }
   }
   return [0,0];
}

dstring matchingSlice(const dstring self, const dchar startChar = '(', const dchar endChar = ')') {
   auto between = self.matching(startChar, endChar);
   return self[between[0]..between[1]];
}


/**
   Matches quotes. Note that escaping the quote character and the escape character itself are handled automatically.
   TODO: Improve it, somethings will go wrong with this simple implementation.
*/
size_t[2] matchingQuotes(const dstring self, const dchar quoteChar = '"', const dchar escapeChar = '\\') {
   size_t start = 0, end = 0;
   bool hasStarted = false;
   bool inEscapeSequence = false;
   for(size_t i = 0; i < self.length; i++) {
      if(self[i] == escapeChar) {
         inEscapeSequence = !inEscapeSequence;
         /* If not in escape, this is start of an escape; if in escape, the escape
         character itself is escaped*/
      } else {
         inEscapeSequence = false;
      }
      if(i != 0 && inEscapeSequence && self[i-1] == escapeChar) {
         continue;
      }
      if(!hasStarted && self[i] == quoteChar) {
         hasStarted = true;
         start = i+1;
      } else if(hasStarted && self[i] == quoteChar) {
         end = i;
         return [start,end];
      }
   }
   return [0,0];
}

dstring matchingQuotesSlice(const dstring self, const dchar quoteChar = '\"', const dchar escapeChar = '\\') {
   size_t[2] between = self.matchingQuotes(quoteChar, escapeChar);
   return self[between[0]..between[1]];
}

alias excludedCharacters = Alias!([
  '#', '$', ':', '\"', '\'', '(', ')', '[', ']', '{', '}',
]);

private bool isExcluded(dchar c, dchar[] excludeds = excludedCharacters) {
   for(size_t i = 0; i < excludeds.length; i++) {
      if(c == excludeds[i]) {
         return true;
      }
   }
   return false;
}

private bool isBoundary(dchar c, dchar[] exludeds = excludedCharacters) {
   return c.isWhite || c.isExcluded(excludedCharacters);
}

dstring identifierSlice(const dstring self, const dchar noEvalChar = '\'', dchar[] excludeds = excludedCharacters) {
   size_t end = 0;
   for(size_t i = 0; i < self.length; i++) {
      if(self[i].isWhite || (!(i == 0 && self[i] == noEvalChar) && self[i].isExcluded)) {
         end = i;
         return self[0..i];
      }
   }
   return self[];
}

public enum TokenType {
   Invalid,
   Identifier,
   Symbol,
   StringLiteral,
   Pair,
   NumberLiteral,
   Expression,
   Block,
   List,
   PairPlaceholder,
}

public struct ValueKeyPairData {
   Token value;
   Token key;
}

public union TokenData {
   dstring identifier;
   dstring symbol;
   dstring stringLiteral;
   real numberLiteral;
   ValueKeyPairData pair;
   Token[] expression;
   Token[] block;
   Token[] list;
}

template tokenConstructor(string type, string inType) {
   string tokenConstructor() {
      string Type = type[0].toUpper.to!string ~ type[1..$];
      return "static Token " ~ type ~ "(" ~ inType ~ " val) {" ~
      "auto ret = new Token;" ~
      "ret.type = TokenType." ~ Type ~ ";" ~
      "ret.data." ~ type ~ " = val;" ~
      "return ret;}";
   }
}

public class Token {
   TokenType type;
   TokenData data;

   this() {}
   mixin(tokenConstructor!("identifier", "dstring"));
   mixin(tokenConstructor!("symbol", "dstring"));
   mixin(tokenConstructor!("stringLiteral", "dstring"));
   mixin(tokenConstructor!("numberLiteral", "real"));
   mixin(tokenConstructor!("pair", "ValueKeyPairData"));
   mixin(tokenConstructor!("expression", "Token[]"));
   mixin(tokenConstructor!("block", "Token[]"));
   mixin(tokenConstructor!("list", "Token[]"));
   static Token pairPlaceholder() {
      auto ret = new Token;
      ret.type = TokenType.PairPlaceholder;
      return ret;
   }

   override string toString() {
      switch(this.type) {
         case TokenType.Identifier:
            return '\n' ~ ("\x1b[31mIdentifier(\"" ~ this.data.identifier ~ "\")\x1b[0m").to!string;
         case TokenType.Symbol:
            return '\n' ~ ("\x1b[32mSymbol(\"" ~ this.data.symbol ~ "\")\x1b[0m").to!string;
         case TokenType.StringLiteral:
            return '\n' ~ ("\x1b[33mStringLiteral(\"" ~ this.data.stringLiteral ~ "\")\x1b[0m").to!string;
         case TokenType.NumberLiteral:
            return '\n' ~ ("\x1b[34mNumberLiteral(" ~ this.data.numberLiteral.to!string ~ ")\x1b[0m").to!string;
         case TokenType.Pair:
            return '\n' ~ ("\x1b[35mPair(" ~ this.data.pair.value.to!string ~ ":" ~ this.data.pair.key.to!string ~ ")\x1b[0m").to!string;
         case TokenType.Expression:
            return '\n' ~ ("\x1b[36mExpression{" ~ this.data.expression.to!string ~ "\x1b[36m}\x1b[0m").to!string;
         case TokenType.Block:
            return '\n' ~ ("\x1b[37mBlock{" ~ this.data.block.to!string ~ "\x1b[37m}\x1b[0m").to!string;
         case TokenType.List:
            return '\n' ~ ("\x1b[0mList{" ~ this.data.list.to!string ~ "}\x1b[0m").to!string;
         case TokenType.PairPlaceholder:
            return '\n' ~ "(PairPlaceholder)";
         default:
            return "";
      }
   }
}

template parseBalanced(dchar open, dchar close, alias kind) {
   void parseBalanced(dstring self, ref size_t pos, ref Token[] ret) {
      size_t[2] between = self[pos..$].matching(open, close);
      between[0] += pos;
      between[1] += pos;
      pos = between[1];
      Token[] inner = parseKut(self[between[0]..between[1]]);
      ret ~= mixin("Token." ~ kind)(inner);
      //return between[1];
   }
}

Token[] parseKut(const dstring toBeParsed) {
   Token[] ret = [];
   const dstring self = to!(const dstring)(toBeParsed);
   for(size_t i = 0; i < self.length; i++) {
      dchar character = self[i];
      if(character.isWhite) {
         continue; /* Cannot be a token, so prevent key-value pair creation from this */
      } else if(character == ':') { /* Value:Key seperator */
         ret ~= Token.pairPlaceholder;
      } else if(character == '#') { /* A comment */
         if(self[i+1] == '[') { /* A block comment */
            size_t[2] between = self[i..$].matching('[', ']');
            i += between[1];
         } else { /* A line comment */
            size_t newLinePos = self[i..$].indexOf('\n');
            i += (newLinePos != -1) ? (newLinePos) : (self.length);
         }
      } else if(character == '"') { /* String literal */
         size_t[2] between = self[i..$].matchingQuotes();
         ret ~= Token.stringLiteral(self[between[0]+i .. between[1]+i]);
         i += between[1];
      } else if(character.isNumber) { /* Number literal */
         dstring num = self[i..$].until!isBoundary.to!dstring;
         ret ~= Token.numberLiteral(num.to!real);
         i += num.length - 1;
      } else if(character == '(') { /* Expression */
         parseBalanced!('(', ')', "expression")(self, i, ret);
      } else if(character == '[') { /* Block */
         parseBalanced!('[', ']', "block")(self, i, ret);
      } else if(character == '{') { /* List */
         parseBalanced!('{', '}', "list")(self, i, ret);
      } else { /* Identifier */
         dstring identifier = null;
         if(self[i] == '\'') {
            identifier = self[i+1..$].identifierSlice;
         } else {
            identifier = self[i..$].identifierSlice;
         }
         if(self[i] == '\'') {
            ret ~= Token.symbol(identifier);
            i += 1;
         } else {
            ret ~= Token.identifier(identifier);
         }
         i += identifier.length-1;
      }
      if(ret.length >= 3 && ret[$-2].type == TokenType.PairPlaceholder) {
         Token val = ret[$-3];
         Token key = ret[$-1];
         ret.popBack();
         ret.popBack();
         ret.popBack();
         ret ~= Token.pair(ValueKeyPairData(val, key));
      }
   }
   return ret;
}

unittest {
   dstring str = `
      ([(ekran "Merhaba, Dünya!" yazsın)] (1 2 <) ise)
      ((96 (3 (2 5 ^) *) = ) sına)
      ('i 0 olsun)
      ([
         (ekran i yazsın)
         ('i 1 artsın)
      ] [(i 5 <)]:olduğu-sürece yap)
      ('dizgem {1 2 3 4} olsun)
      ('kare-dizgem (dizgem [{'x} (x 2 ^)]:ile eşlensin) olsun)
      ([{'x}
         (ekran x yazsın)
      ] kare-dizgem:içinde yap)
   `;
   auto tokens = str.parseKut;
   writeln(tokens);
}

