set -e

# People have started installing packages that overlap with ours into ~/.local
# on telops, which could cause catastrophic collisions, so install a
# sitecustomize.py file to ensure that conda Python doesn't look there:
mkdir -p "${SP_DIR}"
cp "${RECIPE_DIR}/sitecustomize.py" "${SP_DIR}/"

# Ensure that certain env variables are (un)set appropriately for gemini-base:
mkdir -p "${PREFIX}/etc/conda/activate.d"
cp -p "${RECIPE_DIR}/gemini-base_activate.sh" "${PREFIX}/etc/conda/activate.d/"
