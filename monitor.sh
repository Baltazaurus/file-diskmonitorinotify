#!/bin/bash

DIRECTOR_TINTA="test"
RAPORT="modificari.txt"

# Verificam daca avem inotifywait instalat
if ! command -v inotifywait &> /dev/null; then
    echo "EROARE: Trebuie instalat pachetul 'inotify-tools'."
    echo "Comanda: sudo apt-get install inotify-tools"
    exit 1
fi

# Cream folderul tinta in caz ca nu exista
if [ ! -d "$DIRECTOR_TINTA" ]; then
    mkdir -p "$DIRECTOR_TINTA"
fi

echo "=== PORNIRE MONITORIZARE INOTIFY ==="
echo "Urmaresc folderul: $DIRECTOR_TINTA"
echo "Scriu raportul in: $RAPORT"
echo "(Apasa Ctrl+C pentru a opri)"


echo "START MONITORIZARE: $(date)" > "$RAPORT"



inotifywait -m -r -e create -e delete -e modify --format '%w%f %e' "$DIRECTOR_TINTA" | while read CALE EVENIMENT
do
    
    DATA_ORA=$(date "+%H:%M:%S")

    # case cu cele 3 tipuri de evenimente
    MESAJ=""
    
    case "$EVENIMENT" in
        "CREATE"|"CREATE,ISDIR")
            MESAJ="[+] A APARUT un fisier/folder nou: $CALE"
            ;;
        "DELETE"|"DELETE,ISDIR")
            MESAJ="[-] A DISPARUT (sters): $CALE"
            ;;
        "MODIFY")
            MESAJ="[*] S-a MODIFICAT continutul: $CALE"
            ;;
        *)
            MESAJ="[?] Eveniment divers ($EVENIMENT): $CALE"
            ;;
    esac

    # spatiul pe disc---prin df

    SPATIU_LIBER=$(df -h "$DIRECTOR_TINTA" | tail -n 1 | awk '{print $4}')

    # afisare si salvare

    echo "$DATA_ORA | $MESAJ | Spatiu Liber: $SPATIU_LIBER"

    echo "$DATA_ORA | $MESAJ | Spatiu Liber: $SPATIU_LIBER" >> "$RAPORT"
done