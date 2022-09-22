import std.stdio;
import kut.parser : parseKut, Token;

void main() {
   Token[] tokens = parseKut(`(ekran "Merhaba, Dünya" yazsın)`);
   writeln(tokens);
}
