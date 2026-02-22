#!/bin/bash

# Détecte le dossier où le script a été cloné (ex: "tester_cub3D")
SCRIPT_DIR=$(dirname "$0")

# Exécutable à la racine du projet principal
EXEC="./Cub3D"
TEMP_OUT=".test_out"
TIMEOUT=0.4

# Couleurs
GREEN=$'\033[0;32m'
RED=$'\033[0;31m'
BLUE=$'\033[0;34m'
YELLOW=$'\033[1;33m'
RESET=$'\033[0m'

if [ ! -f "$EXEC" ]; then
    echo -e "${RED}Erreur : l'exécutable $EXEC est introuvable.${RESET}"
    exit 1
fi

echo -e "${BLUE}=========================================================================================${RESET}"
printf "${YELLOW}%-32s | %-8s | %-8s | %s${RESET}\n" "Nom du fichier" "Dossier" "Bilan" "Sortie (Message de ton programme)"
echo -e "${BLUE}=========================================================================================${RESET}"

test_directory() {
    local dir=$1
    local expected=$2

    # On cherche les maps dans le dossier cloné
    local target_dir="$SCRIPT_DIR/$dir"

    if [ ! -d "$target_dir" ]; then
        echo "Dossier $target_dir introuvable."
        return
    fi

    for map in "$target_dir"/*; do
        [ -f "$map" ] || continue

        map_name=$(basename "$map")

        # Lancement de Cub3D depuis la racine
        $EXEC "$map" > "$TEMP_OUT" 2>&1 &
        PID=$!

        sleep $TIMEOUT

        if kill -0 $PID 2>/dev/null; then
            kill -9 $PID 2>/dev/null
            wait $PID 2>/dev/null
            actual_state="RUNNING"
            out_msg="Good map (Running)"
        else
            wait $PID 2>/dev/null
            actual_state="STOPPED"
            out_msg=$(head -n 2 "$TEMP_OUT" | tr '\n' ' ' | sed 's/ *$//')
            [ -z "$out_msg" ] && out_msg="[Crash / Segfault / Aucune sortie]"
        fi

        printf "%-32s | %-8s | " "$map_name" "$expected"

        if [ "$expected" == "good" ] && [ "$actual_state" == "RUNNING" ]; then
            printf "${GREEN}%-8s${RESET} | %s\n" "PASS" "$out_msg"
        elif [ "$expected" == "bad" ] && [ "$actual_state" == "STOPPED" ]; then
            printf "${GREEN}%-8s${RESET} | %s\n" "PASS" "${out_msg:0:60}"
        else
            printf "${RED}%-8s${RESET} | %s\n" "FAIL" "${out_msg:0:60}"
        fi
    done
}

# Lance les tests sur les dossiers map/good et map/bad présents dans le repo cloné
test_directory "map/good" "good"
echo -e "${BLUE}-----------------------------------------------------------------------------------------${RESET}"
test_directory "map/bad" "bad"

rm -f "$TEMP_OUT"