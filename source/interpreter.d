module kut.interpreter;

import std.stdio;
import std.uni : toUpper;
import std.conv : to;
import kut.parser : parseKut, Token, TokenType;

enum KutType {
   Undefined,
   Nil,
   Symbol,
   String_,
   Pair,
   Number,
   Block,
   List,
   Object,
   ExternalObject,
}

class KutList {
   KutObject[] sequential;
   KutObject[dstring] pairs;
}

union KutData {
   dstring symbol;
   double number;
   dstring string_;
   KutDataPair pair;
   Token block;
   KutList list;
   // NotYetImplemented object;
   ExternalKutObject externalObject;
}

template kutObjectConstructor(string type, string argType) {
   string kutObjectConstructor() {
      string Type = type[0].toUpper.to!string ~ type[1..$];
      return "static KutObject " ~ type ~ "(" ~ argType ~ " val) {" ~
         "auto ret = new KutObject();" ~
         "ret.type = KutType." ~ Type ~ ";" ~
         "ret.data." ~ type ~ " = val;" ~
         "return ret;}";
   }
}

struct KutDataPair {
   KutObject value;
   dstring key;
}

template isTypeConstructor(string type) {
   string isTypeConstructor() {
      string Type = type[0].toUpper.to!string ~ type[1..$];
      return "bool is" ~ Type ~ "() {" ~
         "return this.type == KutType." ~ Type ~ ";}";
   }
}

KutObject getValue(dstring key, ref KutObject[dstring] immutableVariables, ref KutObject[dstring] variables) {
   if(key in immutableVariables) {
      return immutableVariables[key];
   } else if(key in variables) {
      return variables[key];
   } else {
      return KutObject.undefined;
   }
}

KutObject getImmutableValue(dstring key, ref KutObject[dstring] immutableVariables) {
   if(key in immutableVariables) {
      return immutableVariables[key];
   } else {
      return KutObject.undefined;
   }
}

KutObject getVariableValue(dstring key, ref KutObject[dstring] variables) {
   if(key in variables) {
      return variables[key];
   } else {
      return KutObject.undefined;
   }
}

public class KutObject {
   KutType type;
   KutData data;

   static KutObject undefined() {
      auto ret = new KutObject();
      ret.type = KutType.Undefined;
      return ret;
   }
   static KutObject nil() {
      auto ret = new KutObject();
      ret.type = KutType.Nil;
      return ret;
   }
   mixin(kutObjectConstructor!("symbol", "dstring"));
   mixin(kutObjectConstructor!("number", "double"));
   mixin(kutObjectConstructor!("string_", "dstring"));
   static KutObject pair(KutDataPair pair) {
      auto ret = new KutObject();
      ret.type = KutType.Pair;
      ret.data.pair = pair;
      return ret;
   }
   mixin(kutObjectConstructor!("block", "Token"));
   mixin(kutObjectConstructor!("list", "KutList"));
   mixin(kutObjectConstructor!("externalObject", "ExternalKutObject"));

   mixin(isTypeConstructor!("undefined"));
   mixin(isTypeConstructor!("nil"));
   mixin(isTypeConstructor!("symbol"));
   mixin(isTypeConstructor!("number"));
   mixin(isTypeConstructor!("string_"));
   mixin(isTypeConstructor!("pair"));
   mixin(isTypeConstructor!("block"));
   mixin(isTypeConstructor!("list"));
   mixin(isTypeConstructor!("object"));
   mixin(isTypeConstructor!("externalObject"));

   override string toString() {
      final switch(this.type) {
         case KutType.Undefined:
            return "undefined";
         case KutType.Nil:
            return "nil";
         case KutType.Symbol:
            return "Symbol(" ~ this.data.symbol.to!string ~ ")";
         case KutType.String_:
            return "String(\"" ~ this.data.string_.to!string ~ "\")";
         case KutType.Pair:
            return "Pair(" ~ this.data.pair.value.to!string ~ ":" ~ this.data.pair.key.to!string ~ ")";
         case KutType.Number:
            return "Number(" ~ this.data.number.to!string ~ ")";
         case KutType.Block:
            return "";
         case KutType.List:
            return "";
         case KutType.Object:
            return "";
         case KutType.ExternalObject:
            return "";
      }
   }

   KutObject methodCall(
      dstring method,
      KutObject[] args,
      KutObject[dstring] kwargs,
      ref KutObject[dstring] immutableVariables,
      ref KutObject[dstring] variables
   ) {
      final switch(this.type) {
         case KutType.Undefined:
            return KutObject.undefined;
         case KutType.Nil:
            return KutObject.nil;
         case KutType.Symbol:
            if(method in symbolMethods) {
               return symbolMethods[method](this, args, kwargs, immutableVariables, variables);
            } else {
               return KutObject.undefined;
            }
         case KutType.String_:
            return KutObject.undefined;
         case KutType.Pair:
            return KutObject.undefined;
         case KutType.Number:
            if(method in numberMethods) {
               return numberMethods[method](this, args, kwargs, immutableVariables, variables);
            } else {
               return KutObject.undefined;
            }
         case KutType.Block:
            if(method in blockMethods) {
               return blockMethods[method](this, args, kwargs, immutableVariables, variables);
            } else {
               return KutObject.undefined;
            }
         case KutType.List:
            if(method in listMethods) {
               return listMethods[method](this, args, kwargs, immutableVariables, variables);
            } else {
               return KutObject.undefined;
            }
         case KutType.Object:
            return KutObject.undefined;
         case KutType.ExternalObject:
            return this.data.externalObject.dispatch(this, method, args, kwargs, immutableVariables, variables);
      }
   }
}

alias KutDispatchedMethodType = KutObject function(KutObject self,
   KutObject[] args,
   KutObject[dstring] kwargs,
   ref KutObject[dstring] immutableVariables,
   ref KutObject[dstring] variables
);

KutDispatchedMethodType[dstring] undefinedMethods = null;
KutDispatchedMethodType[dstring] symbolMethods = null;
KutDispatchedMethodType[dstring] stringMethods = null;
KutDispatchedMethodType[dstring] pairMethods = null;
KutDispatchedMethodType[dstring] numberMethods = null;
KutDispatchedMethodType[dstring] blockMethods = null;
KutDispatchedMethodType[dstring] listMethods = null;

void constructMethods() {
   import kut.undefined : getUndefinedMethods;
   import kut.symbol : getSymbolMethods;
   import kut.number : getNumberMethods;
   import kut.list : getListMethods;
   import kut.block : getBlockMethods;
   undefinedMethods = getUndefinedMethods();
   symbolMethods = getSymbolMethods();
   numberMethods = getNumberMethods();
   listMethods = getListMethods();
   blockMethods = getBlockMethods();
};

class ExternalKutObject {
public:
   abstract KutObject dispatch(KutObject self,
      dstring method,
      KutObject[] args,
      KutObject[dstring] kwargs,
      KutObject[dstring] immutableVariables,
      ref KutObject[dstring] variables
   );
}

public KutObject eval(Token token, ref KutObject[dstring] immutableVariables, ref KutObject[dstring] variables) {
   KutObject[] args;
   KutObject[dstring] kwargs;
   switch(token.type) {
      case TokenType.Identifier:
         dstring identifier = token.data.identifier;
         return identifier.getValue(immutableVariables, variables);
      case TokenType.Symbol:
         return KutObject.symbol(token.data.symbol);
      case TokenType.StringLiteral:
         return KutObject.string_(token.data.stringLiteral);
      case TokenType.Pair:
         if(token.data.pair.key.type != TokenType.StringLiteral && token.data.pair.key.type != TokenType.Identifier) {
            throw new Error("Pair keys can only be strings or literals!");
         }
         if(token.data.pair.key.type == TokenType.StringLiteral) {
            return KutObject.pair(KutDataPair(token.data.pair.value.eval(immutableVariables, variables), token.data.pair.key.data.stringLiteral));
         }
         return KutObject.pair(KutDataPair(token.data.pair.value.eval(immutableVariables, variables), token.data.pair.key.data.identifier));
      case TokenType.NumberLiteral:
         return KutObject.number(token.data.numberLiteral.to!double);
      case TokenType.Expression:
         if(token.data.expression.length == 0) {
            return KutObject.undefined;
         } else if(token.data.expression.length == 1) {
            return token.data.expression[0].eval(immutableVariables, variables);
         }
         Token subjectToken = token.data.expression[0];
         Token verbToken = token.data.expression[$-1];
         KutObject subject = subjectToken.eval(immutableVariables, variables);
         if(verbToken.type != TokenType.StringLiteral && verbToken.type != TokenType.Identifier) {
            throw new Error("Method names can only be strings or identifiers!");
         }
         dstring verb = (verbToken.type == TokenType.Identifier) ? (verbToken.data.identifier) : (verbToken.data.stringLiteral);
         foreach(Token exprToken; token.data.expression[1..$-1]) {
            KutObject innerObject = exprToken.eval(immutableVariables, variables);
            if(innerObject.type == KutType.Pair) {
               kwargs[innerObject.data.pair.key] = innerObject.data.pair.value;
            } else {
               args ~= innerObject;
            }
         }
         return subject.methodCall(verb, args, kwargs, immutableVariables, variables);
      case TokenType.Block:
         return KutObject.block(token);
      case TokenType.List:
         auto list = new KutList();
         foreach(Token listToken; token.data.list) {
            KutObject innerObject = listToken.eval(immutableVariables, variables);
            if(innerObject.isPair) {
               list.pairs[innerObject.data.pair.key] = innerObject.data.pair.value;
            } else {
               list.sequential ~= innerObject;
            }
         }
         return KutObject.list(list);
      default:
         return KutObject.undefined;
   }
}
public void evaluate(Token[] tokens, ref KutObject[dstring] immutableVariables, ref KutObject[dstring] variables) {
   if(symbolMethods == null) {
      constructMethods();
   }
   for(size_t i = 0; i < tokens.length; i++) {
      switch(tokens[i].type) {
         case TokenType.Expression:
            tokens[i].eval(immutableVariables, variables);
         break;
         default:
            throw new Error("Top declarations must be all expressions!");
      }
   }
}
