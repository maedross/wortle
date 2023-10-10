# Wortle
## Überblick
Das ist eine kleine Haskell-App, die das Spiel "Wordle" imitiert. Ich habe ein Paar Änderungen enthaltet:
* Es gibt nicht nur Wörter mit 5 Buchstaben. Der Benutzer\*in darf die Länge wählen, oder sie dürfen die App zufällig wählen lassen. Die App zeigt dem Benutzer\*in die Länge des gewählten Wortes an.
* Der Benutzer*in darf eine Anzahl von Versuche wählen. Der Standard ist noch 5.
* Die App enthaltet ein "leicht Modus", in dem man nicht nur Wörter als Versuche wählen muss. Zum Beipsiel, man könnte "aeiou" für ein Wörter mit 5 Buchstaben wählen.

## Herunterladen
Man muss mindestens **beide** wortle.exe und Wortliste.txt herunterladen. Öffnen Sie einfach wortle.exe und das Spiel wird in ihrem Terminal angezeigt!

Wenn Sie die App bearbeiten möchte, herunterladen Sie [Haskell](https://www.haskell.org/downloads/) und klonen Sie das Projekt. Sie können die ausführbare Datei neu erstellen, indem Sie den Befehl `cabal build`. Sie werden die neue ausführbare Datei in `dist-newstyle\build\x86_64-windows\ghc-9.2.5\wortle-0.1.0.0\x\wortle\build\wortle\wortle.exe`. Sie können die App ausführen durch `cabal run` oder durch Kopieren der ausführbaren Datei in das Stammverzeichnis des Projektordners starten. Ich habe das nicht auf MacOS oder Linux getestet, und es kann anders funktionieren.